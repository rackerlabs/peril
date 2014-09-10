module Peril
  module Notifiers

    class SlackNotifier < Notifier
      include Loggable

      NEW_INCIDENT_MESSAGES = [
        'New Peril Incident!',
        'Heads up, incoming!',
        'Someone needs help!',
        'A Developer is in Peril!',
        'Fix it fix it fix it fix it fix it',
        'BWEEEEEP BWEEEEP BWEEEEP'
      ]

      HEADERS = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }

      attr_accessor :webhook_url, :username

      def setup
        unless @webhook_url
          raise RuntimeError.new("SlackNotifier requires a webhook URL.")
        end

        @username ||= "peril"
      end

      def process(event, incident)
        return unless incident.just_created?

        message = []
        message << "*#{NEW_INCIDENT_MESSAGES[rand(NEW_INCIDENT_MESSAGES.size)]}*"

        prefix = "_from #{incident.original_reporter}:_"
        if incident.url
          message << "#{prefix} <#{incident.url}|#{incident.title}>"
        else
          message << "#{prefix} #{incident.title}"
        end
        unless incident.parsed_tags.empty?
          message << "Tags: #{incident.parsed_tags.join ', '}"
        end

        HTTParty.post(@webhook_url, headers: HEADERS, body: {
          username: @username,
          text: message.join("\n"),
          icon_emoji: ':rackspace:',
          mrkdwn: true,
          unfurl_links: true
        }.to_json)
      end
    end

  end
end
