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

    # Repeatedly `#scan` the queue for Events. When any are received, yield each.
    # Stop polling if the called block returns the sentinel value `:stop`.
    #
    # @yieldparam event [Event] An Event deserialized from a queue message.
    # @yieldreturn [Symbol] `:stop` to stop polling.
    def poll
      loop do
        scan.each { |e| return if yield(e) == :stop }
        sleep Config.get.default(:poll_time, 5)
      end
    end
  end

end
