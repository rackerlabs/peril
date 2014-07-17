module Peril
  module Slurpers

    class Mailslurp < Slurper
      include Loggable

      def setup
        var = 1234

        webhook do
          get '/thing' do
            logger.info 'Yes.'
            "var = #{var}"
          end

          post '/incoming' do
            logger.info 'Got a message!'

            # Construct an event body from the message.
            subject = params['Subject'].gsub(/^(?:(?:Re:|Fwd:)\s*)+/, '')

            200
          end
        end
      end
    end

  end
end
