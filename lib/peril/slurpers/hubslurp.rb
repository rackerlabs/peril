#!/usr/bin/env ruby

require 'fog'
require 'octokit'
require 'rufus-scheduler'
require 'log4r'
require 'yaml'

# Constants

CONFIG_PATH = File.join __dir__, 'config.yml'
VERSION_PATH = File.join __dir__, 'VERSION'
LAST_PATH = File.join __dir__, '.last_check'

# Support

class Repository
  attr_reader :name, :tags

  def initialize(name, tags)
    @name, @tags = name, tags
  end

  def self.from_h(hash)
    unless hash['name']
      raise RuntimeError.new("Malformed repository hash: #{hash.inspect}")
    end
    new(hash['name'], hash['tags'] || [])
  end
end

# Configuration

def configure
  @config = YAML.load_file(CONFIG_PATH)
  return if @config == @prior

  @version = File.read(VERSION_PATH).chomp

  # Log4r

  @logger = Log4r::Logger.new 'default'
  @logger.outputters = Log4r::Outputter.stdout
  @logger.level = Log4r.const_get(@config['log_level'] || 'INFO')

  # Fog

  @logger.info "Authenticating to Rackspace as #{@config['rackspace_username']}."
  service = Fog::Rackspace::Queues.new(
    rackspace_username: @config['rackspace_username'],
    rackspace_api_key: @config['rackspace_api_key'],
    rackspace_region: @config['rackspace_region']
  )

  @q = service.queues.get(@config['queue_name'])
  if @q.nil?
    @q = service.queues.create(key: @config['queue_name'])
    @logger.info "Created new queue #{@config['queue_name']}."
  else
    @logger.info "Found existing queue #{@config['queue_name']}."
  end

  # Octokit

  @octokit = Octokit::Client.new access_token: @config['github_access_token']

  # Repositories

  @repositories = @config['repositories'].map do |hash|
    Repository.from_h hash
  end

  # Remember this configuration so we don't re-authenticate unnecessarily.
  @prior = @config
end

configure

# Main loop

@logger.info "Launching HubSlurp version #{@version}."
@logger.debug 'Debug logging is enabled.'

scheduler = Rufus::Scheduler.new

scheduler.interval(@config['interval'] || '5m') do
  @logger.debug 'Awake again.'

  ts = Time.now
  if @last_check.nil?
    if File.exist? LAST_PATH
      @last_check = Time.at(File.read(LAST_PATH).to_i)
    else
      # Default to a day ago.
      @last_check = ts - 86400
    end
  end

  configure

  keyword_pattern = Regexp.new(
    @config['keywords'].map { |kw| Regexp.escape kw }.join('|'),
    Regexp::IGNORECASE
  )

  @repositories.each do |repo|
    @logger.info "Polling for issues in #{repo.name} since #{@last_check}."

    @octokit.list_issues(repo.name, since: @last_check).each do |issue|
      # Check for keyword matches.
      if keyword_pattern =~ issue.title || keyword_pattern =~ issue.body
        @logger.info "#{repo.name}##{issue.number} contains a keyword match."

        # Publish an event.
        @q.enqueue(
          {
            reporter: "hubslurp-#{@version}",
            url: issue.url,
            title: issue.title,
            origin_id: issue.id,
            incident_date: issue.created_at.to_i,
            tags: repo.tags
          },
          3600
        )
      else
        @logger.debug "No hit in #{repo.name}##{issue.number}."
      end
    end
  end

  @last_check = ts
  File.write(LAST_PATH, @last_check.to_i.to_s)

  @logger.debug "Rate limit remaining: #{@octokit.rate_limit.remaining}"
  @logger.debug 'Back to sleep.'
end

scheduler.join
