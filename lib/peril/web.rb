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

        Incident.where('updated_at > ?', since).order(:updated_at).map do |i|
          {
            unique_id: i.unique_id,
            original_reporter: i.original_reporter,
            url: i.url,
            title: i.title,
            tags: (i.tags || '').split(/\s*,\s*/),
            assignee: i.assignee,
            assigned_at: i.assigned_at.to_i,
            completed_at: i.completed_at.to_i,
            extra: i.extra,
            created_at: i.created_at.to_i,
            updated_at: i.updated_at.to_i
          }
        end.to_json
      end
    end

  end
end
