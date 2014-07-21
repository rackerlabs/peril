module Peril
  module Slurpers

    class Mailslurp < Slurper
      include Loggable

      def setup
        var = 1234

        webhook do
          get '/mailslurp/info' do
            "Mailslurp is up and running."
          end

          post '/mailslurp/incoming' do
            logger.info 'Email: received!'

            # Construct an event body from the message.
            subject = params['Subject'].gsub(/^(?:(?:Re:|Fwd:)\s*)+/, '')
            emit(Event.from_h(
              reporter: 'mailslurp',
              title: subject,
              incident_date: Time.parse(params['Date']).to_i
            ))

            200
          end
        end
      end
    end

  end
end
