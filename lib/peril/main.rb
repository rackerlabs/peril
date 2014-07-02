require 'rufus-scheduler'

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

      logger.debug 'establishing database connection'
      config.dbconnect!

      logger.debug 'activating notifiers'
      Notifier.activate
      logger.debug "active notifier count: #{Notifier.known.size}"

      logger.debug 'activating slurpers'
      Slurper.activate
      logger.debug "active slurper count: #{Slurper.known.size}"

      scheduler = Rufus::Scheduler.new

      logger.info 'all systems go. commence primary ignition'
      scheduler.every config.default(:poll_time, '5m') do
        Slurper.poll do |event|
          logger.debug "Processing: #{event.inspect}"
          incident = Incident.for_event(event)
          Notifier.handle(event, incident)
        end
      end

      scheduler.join
    end
  end
end
