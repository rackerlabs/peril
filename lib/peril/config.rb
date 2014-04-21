require 'yaml'
require 'active_record'
require 'log4r'

module Peril

  # To be raised if a required configuration option is absent.
  #
  class MissingConfigError < RuntimeError
  end

  # Access Peril's application configuration, as specified in `peril.yml` or
  # `peril.yml.example`.
  #
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
    #
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
    #
    def optional(*keypath)
      default(keypath, nil)
    end

    # A configuration option that *must* be present for the configuration to
    # make sense.
    #
    # @param keypath [String|Symbol] A sequence of keys to follow.
    # @return [Object] The object at that key path.
    # @raises [MissingConfigError] If the key path is not present.
    #
    def required(*keypath)
      v = default(keypath, SENTINEL)
      if v.equal? SENTINEL
        path = keypath.join(', ')
        raise MissingConfigError.new("Missing required configuration option: #{path}")
      end
      v
    end

    # Connect ActiveRecord to the database using these settings.
    #
    def dbconnect!
      logger = Log4r::Logger.new 'activerecord'
      logger.outputters = Log4r::Outputter.stdout
      logger.level = Log4r.const_get default(:log_level, 'INFO')

      ActiveRecord::Base.establish_connection required(:db)
      ActiveRecord::Base.logger = logger
    end

    # Bundle Rackspace credentials together.
    #
    # @return [Hash] All `:rackspace` API credentials for fog.
    # @raise [MissingConfigError] If one or more of the required credentials
    #   are absent.
    #
    def rackspace_credentials
      {
        rackspace_username: required(:rackspace, :username),
        rackspace_api_key: required(:rackspace, :api_key),
        rackspace_region: required(:rackspace, :region)
      }
    end

    # Configure the root logger using optional settings from the
    # `logger` subsection.
    #
    # Recognized settings:
    # * `level`: The master logging level for all loggers. One of
    #     `DEBUG`, `INFO`, `WARN`, `ERROR`, or `FATAL`. Defaults to
    #     `INFO`.
    # * `filename`: The path to write logging messages to. Defaults
    #     to stdout.
    # * `maxsize`: The maximum filesize in bytes before rolling over.
    #     Default: 10485760 (10MB).
    #
    def configure_logging!
      root = Log4r::Logger.root

      level_name = default(:logging, :level)
      root.level = Log4r.const_get(level_name)

      file_name = optional(:logging, :filename)
      if file_name
        max_size = default([:logging, :maxsize], 10485760)

        root.outputters = Log4r::RollingFileOutputter(
          filename: file_name,
          maxsize: max_size
        )
      else
        root.outputters = Log4r::Outputter.stdout
      end
    end

    # Configure a logger for the named scope, configured with a logging
    # level and output configuration as specified by the Config.
    #
    def configure_logger(scope)
      logger = Log4r::Logger.new scope

      level_name = optional(:logging, scope, :level)
      logger.level = Log4r.const_get(level_name) if level_name
    end

    # The default configuration environment for this process.
    #
    # @return [String] The configuration environment.
    #
    def self.env
      ENV['PERIL_ENV'] || 'development'
    end

    # Find and deserialize the configuration as a `Hash`. If you want a
    # `Config` instance, use `::get`.
    #
    # @param environment [String] The current execution environment.
    # @return [Hash] The deserialized YAML from the configuration file.
    #
    def self.load
      %w(peril.yml peril.yml.example).each do |fname|
        path = File.join ROOT, fname
        return YAML.load_file(path)[env] if File.exists? path
      end
      raise 'Unable to find a configuration file.'
    end

    # Access the lazily-initialized One True Configuration Instance.
    #
    # @param environment [String] Current execution environment. Defaults to
    #   `PERIL_ENV`, or
    # @return [Config] An initialized Config object.
    def self.get(environment = env)
      @config ||= new(load(environment))
    end

  end
end
