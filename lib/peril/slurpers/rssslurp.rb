require 'nokogiri'
require 'date'
require 'restclient'

module Peril
  module Slurpers

    class Rssslurp < Slurper
      include Loggable

      class FeedItem
          attr_accessor :url, :title, :time, :body, :tags

          def to_event
            Event.from_h(
              url: url,
              reporter: 'rssslurp',
              title: title,
              tags: tags,
              incident_date: time.to_i
            )
          end

          def self.from_node node
            new.tap do |i|
              i.url = node.at_css('link').content
              i.title = node.at_css('title').content
              i.body = node.at_css('description').content
              i.time = DateTime.parse(node.at_css('pubDate').content).to_time
              i.tags = []
            end
          end
      end

      class Feed
        def initialize(logger, url, tags, filter)
          @logger, @url, @tags, @filter = logger, url, tags, filter
        end

        def items
          begin
            @logger.debug "GET #{@url}"
            content = RestClient.get(@url).body
            Nokogiri::XML(content).xpath("//rss/channel/item").map do |node|
              FeedItem.from_node(node)
            end.map(&@filter).reject(&:nil?)
          rescue => e
            @logger.error "Unable to fetch #{@url}! #{e.message}"
            []
          end
        end
      end

      def initialize
        @feeds = []
      end

      def feed(url, tags = [], &block)
        filter = block || Proc.new { |i| i }
        @feeds << Feed.new(logger, url, tags, filter)
      end

      def setup
        if @feeds.empty?
          raise RuntimeError.new("Rssslurp requires at least one feed!")
        end
      end

      def next_events
        logger.info "Fetching RSS items from #{@feeds.size} feeds."
        @feeds.flat_map(&:items).map(&:to_event)
      end
    end

  end
end
