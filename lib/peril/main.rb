module Peril

  # Entry point for the CLI. Configure all the things, then poll the Cloud
  # Queue and fire all notifiers each time an Event arrives.
  #
  class Main
    include Loggable

    # Start the loop.
    #
    def go
      config = Peril::Config.get
      config.dbconnect!

      qr = QueueReader.new
      qr.find_or_create_queue
      qr.poll do |event|
        logger.info "Got: #{event.inspect}"
      end
    end
  end
end
