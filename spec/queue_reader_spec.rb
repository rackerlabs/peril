require_relative 'spec_helpers'

describe QueueReader do
  let(:qr) { QueueReader.new }
  let(:config) { Peril::Config.get }

  it 'finds an existing Cloud Queue' do
    puts config.inspect
    service = Fog::Rackspace::Queues.new(
      rackspace_username: config['rackspace']['username'],
      rackspace_api_key: config['rackspace']['api_key']
    )

    existing = service.queues.create name: config['queue_name']

    found = qr.find_or_create_queue
    found.must_be_same_as existing
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
