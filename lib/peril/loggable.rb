require_relative 'config'

module Peril

  # Mix in to another object to provide a `logger` method that emits to a
  # logger that's named for its class, downcased.
  module Loggable
    def self.included(klass)
      Config.get.configure_logger(klass.name)
    end

    def logger
      @logger ||= Logger[self.class.name]
    end
  end

end
