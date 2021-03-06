require 'octokit'

module Peril
  module Slurpers

    class Hubslurp < Slurper
      include Loggable

      attr_accessor :access_token, :repositories
      attr_accessor :last_check

      Repository = Struct.new(:name, :tags, :pattern)

      def initialize
        @repositories = []

        # Start checking a day ago.
        @last_check = Time.now - 86400
      end

      def repository(name, tags = [], keywords = [])
        if keywords.empty?
          pattern = /./
        else
          pattern = Regexp.new(
            keywords.map { |kw| Regexp.escape kw }.join('|'),
            Regexp::IGNORECASE
          )
        end

        @repositories << Repository.new(name, tags, pattern)
      end

      def setup
        unless @access_token
          raise RuntimeError.new('HubSlurp requires an access_token.')
        end

        if @repositories.empty?
          raise RuntimeError.new('You must specify at least one repository.')
        end

        @octokit = Octokit::Client.new access_token: @access_token
      end

      def next_events
        events = []
        ts = Time.now

        @repositories.each do |repo|
          logger.info "Polling for issues in #{repo.name} since #{@last_check}."

          @octokit.list_issues(repo.name, since: @last_check).each do |issue|
            # Check for a keyword match.
            if repo.pattern =~ issue.title || repo.pattern =~ issue.body
              logger.info "#{repo.name}##{issue.number} contains a keyword match."
              events << Event.from_h(
                reporter: 'hubslurp',
                url: issue.html_url,
                title: issue.title,
                origin_id: issue.id,
                tags: repo.tags
              )
            else
              logger.debug "No hit in #{repo.name}##{issue.number}."
            end
          end
        end

        @last_check = ts
        logger.info "Rate limit remaining: #{@octokit.rate_limit.remaining}"

        events
      end
    end

  end
end
