module Peril

  # Create Events from a Cloud Queue.
  class QueueReader
    attr_reader :queue

    # Find the existing Cloud Queue, creating it if necessary.
    def find_or_create_queue
      config = Config.get
      username = config.fetch('rackspace', {}).fetch('username', 'mocking')
      apikey = config.fetch('rackspace', {}).fetch('api_key', 'mocking')

      service = Fog::Rackspace::Queues.new(
        rackspace_username: username,
        rackspace_api_key: apikey
      )

      @queue = service.queues.get(config['queue_name'])
      if @queue.nil?
        @queue = service.queues.create name: config['queue_name']
      end
      @queue
    end

    # Query the queue for any pending messages. Deserialize any discovered
    # into Events.
    #
    # @return [Array<Event>] A (possibly empty) set of Events that were
    #   discovered.
    def scan
      @queue.messages.map do |message|
        doc = JSON.parse(message.body)
        e = Event.from_h(doc)
        message.destroy
        e
      end
    end
  end

end
