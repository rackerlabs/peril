require_relative 'spec_helpers'

describe QueueReader do
  it 'polls a Cloud Queue for events' do
    qr = QueueReader.new

    q = qr.find_or_create_queue
    0.upto(5) do |i|
      q.enqueue "{ \"unique_id\": \"#{i}#{i}\", \"reporter\": \"minitest\" }", 3600
    end

    es = qr.poll
    es.map(&:unique_id).must_equal %w{00 11 22 33 44 55}
  end
end
