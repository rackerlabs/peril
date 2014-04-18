module Peril

  # Create Events from a Cloud Queue.
  class QueueReader
    attr_reader :queue

    # Find the existing Cloud Queue, creating it if necessary.
    def find_or_create_queue
      config = Config.get
      service = Fog::Rackspace::Queues.new(config.rackspace_credentials)

      qname = config.default(:queue_name, 'peril_events')
      @queue = service.queues.get qname
      if @queue.nil?
        @queue = service.queues.create name: qname
      end
      @queue
    end

    # Query the queue for any pending messages. Deserialize any discovered
    # into Events.
    #
    # @yieldparam [Event] A (possibly invalid) Event that was parsed.
    #
    def scan
      @queue.messages.each do |message|
        doc = JSON.parse(message.body)
        r = yield Event.from_h(doc)
        message.destroy
        return :stop if r == :stop
      end
    end

    # Repeatedly `#scan` the queue for Events. When any are received, yield each.
    # Stop polling if the called block returns the sentinel value `:stop`.
    #
    # @yieldparam event [Event] An Event deserialized from a queue message.
    # @yieldreturn [Symbol] `:stop` to stop polling.
    #
    def poll
      loop do
        r = scan { |e| yield e }
        return if r == :stop
        sleep Config.get.default(:poll_time, 5)
      end
    end
  end

end
