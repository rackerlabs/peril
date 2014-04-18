require_relative 'spec_helpers'

describe QueueReader do
  let(:qr) { QueueReader.new }
  let(:config) { Peril::Config.get }
  let(:qname) { config.default(:queue_name, 'peril_events') }
  let(:service) do
    Fog::Rackspace::Queues.new(config.rackspace_credentials)
  end

  before { service.queues.each(&:destroy) }

  def with_service
    Fog::Rackspace::Queues.stub :new, service do
      yield
    end
  end

  it 'finds an existing Cloud Queue' do
    with_service do
      existing = service.queues.create name: qname

      found = qr.find_or_create_queue
      found.name.must_equal existing.name
    end
  end

  it 'creates a new Cloud Queue' do
    with_service do
      service.queues.all.must_be :empty?

      created = qr.find_or_create_queue
      created.name.must_equal qname
    end
  end

  describe 'with events waiting' do
    before do
      q = qr.find_or_create_queue
      0.upto(5) do |i|
        q.enqueue "{ \"unique_id\": \"#{i}#{i}\", \"reporter\": \"minitest\" }", 3600
      end
    end

    it 'scans a Cloud Queue for events' do
      qr.scan.map(&:unique_id).must_equal %w(00 11 22 33 44 55)
    end

    it 'polls a Cloud Queue for events' do
      seen = []
      qr.poll do |event|
        seen << event
        :stop if seen.size >= 6
      end
      seen.map(&:unique_id).must_equal %w(00 11 22 33 44 55)
    end
  end
end
