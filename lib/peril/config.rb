require 'yaml'
require 'active_record'
require 'log4r'

module Peril

  # To be raised if a required configuration option is absent.
  class MissingConfigError < RuntimeError
  end

  # Access Peril's application configuration, as specified in `peril.yml` or
  # `peril.yml.example`.
  class Config
    ROOT = File.join __dir__, '..', '..'
    SENTINEL = Object.new

    def initialize(hash)
      @hash = hash
    end

    # Access a configuration key, returning `value` if it's not present.
    #
    # @param keypath [Array<String>|Array<Symbol>|String|Symbol] The key or
    #   key path to access.
    # @param value [Object] The default object to return if the keypath is not
    #   present.
    # @return [Object] The object at this setting, or `value` if it is absent.
    def default(keypath, value)
      Array(keypath).inject(@hash) do |h, key|
        v = h[key.to_s]
        return value if v.nil?
        v
      end
    end

    # The common case of `#default`, where the default value is `nil`.
    #
    # @param keypath [String|Symbol] A sequence of keys to follow.
    # @return [Object|nil] The object at that key path, or `nil` if it
    #   is not present.
    def optional(*keypath)
      default(keypath, nil)
    end

    # A configuration option that *must* be present for the configuration to
    # make sense.
    #
    # @param keypath [String|Symbol] A sequence of keys to follow.
    # @return [Object] The object at that key path.
    # @raises [MissingConfigError] If the key path is not present.
    def required(*keypath)
      v = default(keypath, SENTINEL)
      if v.equal? SENTINEL
        path = keypath.join(', ')
        raise MissingConfigError.new("Missing required configuration option: #{path}")
      end
      v
    end

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
