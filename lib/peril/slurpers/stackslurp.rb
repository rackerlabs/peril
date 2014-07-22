require 'restclient'
require 'json'

module Peril
  module Slurpers

    class Stackslurp < Slurper
      include Loggable

      SEARCH_API = 'https://api.stackexchange.com/2.2/search'

      def tags(tags)
        @tags = tags
      end

      def sites(sites)
        @sites = sites
      end

      def since(time)
        @since = time
      end

      def key(apikey)
        @key = apikey
      end

      def setup
        raise RuntimeError.new('Stackslurp requires at least one tag') if @tags.nil? || @tags.empty?

        raise RuntimeError.new('Stackslurp requires a site') if @sites.nil? || @sites.empty?

        raise RuntimeError.new('Stackslurp requires an API key') if @key.nil?

        # Default to a day ago
        @since = Time.now - 86400 if @since.nil?
      end

      def next_events
        @sites.flat_map do |site|
          begin
            logger.info "Querying for new questions on #{site}."

            from_date = @since.to_i
            @since = Time.now
            resp = RestClient.get SEARCH_API,
              'Accept-Encoding' => 'gzip',
              'Accept' => 'application/json',
              :params => {
                fromdate: from_date,
                order: 'desc',
                sort: 'creation',
                tagged: @tags.join(';'),
                site: site,
                key: @key
              }
            JSON.parse(resp.body)['items'].map { |q| question_to_event q }
          rescue RestClient::Exception => e
            logger.error "Unable to contact StackExchange API! #{e.message}"
            logger.error e.inspect
            []
          end
        end
      end

      private

      def question_to_event(question)
        Event.from_h(
          url: question['link'],
          tags: question['tags'],
          incident_date: question['creation_date'],
          origin_id: question['question_id'],
          title: question['title'],
          reporter: 'stackslurp'
        )
      end

    end

  end
end
