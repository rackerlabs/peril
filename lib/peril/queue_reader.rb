module Peril

  # Create Events from a Cloud Queue.
  #
  class QueueReader
    include Loggable
    attr_reader :queue

    # Find the existing Cloud Queue, creating it if necessary.
    #
    def find_or_create_queue
      config = Config.get

      creds = config.rackspace_credentials
      logger.info "authenticating to Cloud Queues as [#{creds[:rackspace_username]}]"
      service = Fog::Rackspace::Queues.new(creds)

      qname = config.default(:queue_name, 'peril_events')
      logger.info "locating queue [#{qname}]"
      @queue = service.queues.get qname
      if @queue.nil?
        logger.warn "creating queue [#{qname}]"
        @queue = service.queues.create name: qname
      else
        logger.debug "found existing queue"
      end
      @queue
    end

    # Query the queue for any pending messages. Deserialize any discovered
    # into Events.
    #
    # @yieldparam [Event] A (possibly invalid) Event that was parsed.
    #
    def scan
      @queue.messages.all.each do |message|
        logger.debug "processing event from message [#{message.id}]"

        r = yield Event.from_h(message.body)

        logger.debug "disposing of message [#{message.id}]"
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
        logger.debug "polling at #{Time.now}"
        r = scan { |e| yield e }
        return if r == :stop
        sleep Config.get.default(:poll_time, 5)
      end
    end
  end

end
