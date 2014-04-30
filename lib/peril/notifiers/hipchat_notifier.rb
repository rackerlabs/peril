require 'hipchat'

module Peril
  module Notifiers
    class HipChatNotifier < Notifier
      include Loggable

      attr_accessor :api_token, :username, :room

      def setup
        unless @api_token
          raise RuntimeError.new('HipChatNotifier requires an api_token.')
        end

        @username ||= 'Peril'
        @room ||= 'Peril Alerts'
        @client = HipChat::Client.new(@api_token, api_version: 'v2')
      end

      def process(event, incident)
        return unless incident.just_created?

        message = []
        message << 'Someone needs help!'
        if incident.url
          message << "<a href='#{incident.url}'>#{incident.title}</a>"
        else
          message << "<strong>#{incident.title}</strong>"
        end

        @client[@room].send(@username, message.join('<br/>'))
      end

    end
  end
end
