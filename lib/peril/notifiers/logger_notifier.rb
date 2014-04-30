module Peril
  module Notifiers
    class LoggerNotifier < Notifier
      include Loggable

      def process(event, incident)
        logger.info "event: #{event.inspect} incident: #{incident.inspect}"
      end

    end
  end
end
