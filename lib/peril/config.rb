require 'yaml'
require 'active_record'
require 'log4r'

module Peril
  module Config
    ROOT = File.join __dir__, '..', '..'

    def self.env
      ENV['PERIL_ENV'] || 'development'
    end

    def self.load(environment = env)
      %w(peril.yml peril.yml.example).each do |fname|
        path = File.join ROOT, fname
        return YAML.load_file(path)[environment] if File.exists? path
      end
      raise 'Unable to find a configuration file.'
    end

    def self.get
      @config ||= load
    end

    def self.dbconnect!(environment = env)
      conf = get
      logger = Log4r::Logger.new 'activerecord'
      logger.outputters = Log4r::Outputter.stdout

      if conf['log_level']
        logger.level = Log4r.const_get conf['log_level']
      else
        logger.level = Log4r::INFO
      end

      ActiveRecord::Base.establish_connection conf['db']
      ActiveRecord::Base.logger = logger
    end

  end
end
