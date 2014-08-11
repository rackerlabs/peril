require 'rufus-scheduler'

module Peril

  # Entry point for the CLI. Configure all the things, then poll the Slurpers
  # and fire all notifiers each time an Event arrives.
  #
  class Main
    include Loggable

    # Perform setup common to both entry points.s
    #
    def setup
      @config = Peril::Config.get

      logger.debug 'establishing database connection'
      @config.dbconnect!

      logger.debug 'activating notifiers'
      Notifier.activate
      logger.debug "active notifier count: #{Notifier.known.size}"

      logger.debug 'activating slurpers'
      Slurper.activate
      logger.debug "active slurper count: #{Slurper.known.size}"
    end

    # Start the polling loop.
    #
    def poll
      setup
      scheduler = Rufus::Scheduler.new

      logger.info 'all systems go. commence primary ignition'
      scheduler.every @config.default(:poll_time, '5m') do
        Slurper.poll do |event|
          logger.debug "Processing: #{event.inspect}"
          incident = Incident.for_event(event)
          Notifier.handle(event, incident)
        end
      end

      scheduler.join
    end

    # Inject slurpers into a Sinatra base object.
    #
    def webhooks(sinatra)
      setup
      sinatra.helpers WebhookHelpers

      Slurper.install_webhooks(sinatra)
    end
  end

  # Helper methods available within the `webhook` block of a Slurper.
  #
  module WebhookHelpers

    def emit(event)
      incident = Incident.for_event(event)
      Notifier.handle(event, incident)
    end

  end
end
