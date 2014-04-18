require_relative 'spec_helpers'

describe QueueReader do
  let(:qr) { QueueReader.new }
  let(:config) { Peril::Config.get }
  let(:service) do
    Fog::Rackspace::Queues.new(
      rackspace_username: config['rackspace']['username'],
      rackspace_api_key: config['rackspace']['api_key']
    )
  end

  before { service.queues.each(&:destroy) }

  def with_service
    Fog::Rackspace::Queues.stub :new, service do
      yield
    end
  end

  it 'finds an existing Cloud Queue' do
    with_service do
      existing = service.queues.create name: config['queue_name']

      found = qr.find_or_create_queue
      found.name.must_equal existing.name
    end
  end

  it 'creates a new Cloud Queue' do
    with_service do
      service.queues.all.must_be :empty?

      created = qr.find_or_create_queue
      created.name.must_equal config['queue_name']
    end
  end

  it 'polls a Cloud Queue for events' do
    q = qr.find_or_create_queue
    0.upto(5) do |i|
      q.enqueue "{ \"unique_id\": \"#{i}#{i}\", \"reporter\": \"minitest\" }", 3600
    end

    es = qr.poll
    es.map(&:unique_id).must_equal %w{00 11 22 33 44 55}
  end
end
