require 'yaml'

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
  end
end
