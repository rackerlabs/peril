# Global webhooks.

require 'json'

module Peril
  module Web

    def self.included(sinatra)
      sinatra.get '/' do
        'Online and ready to receive.'
      end

      sinatra.get '/incidents' do
        unless params[:since]
          halt 400, "You're missing the required 'since' parameter."
        end
        since = Time.at(params[:since].to_i)

        headers 'Content-Type' => 'application/json'

        ts = ->(t) { t && t.to_i }

        Incident.where('updated_at > ?', since).order(:updated_at).map do |i|
          {
            unique_id: i.unique_id,
            original_reporter: i.original_reporter,
            url: i.url,
            title: i.title,
            tags: (i.tags || '').split(/\s*,\s*/),
            assignee: i.assignee,
            assigned_at: ts[i.assigned_at],
            completed_at: ts[i.completed_at],
            extra: i.extra,
            created_at: ts[i.created_at],
            updated_at: ts[i.updated_at]
          }
        end.to_json
      end
    end

  end
end
