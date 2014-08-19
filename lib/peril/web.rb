# Global webhooks.

module Peril
  module Web

    def self.included(sinatra)
      sinatra.get '/' do
        'Online and ready to receive.'
      end
    end

  end
end
