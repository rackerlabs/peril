require_relative 'plugin_set'

module Peril

  # Extend in to the superclass of a plugin hierarchy to track activated plugins
  # with a PluginSet.
  #
  module Pluggable

    def self.extended(klass)
      # Define a #plugin_set method on the class that actually called
      # "extend Pluggable" that returns the PluginSet instance. This lets
      # us use a single PluginSet for the entire hierarchy, without using
      # class variables.

      the_set = PluginSet.new(klass)

      klass.instance_eval do
        define_singleton_method(:plugin_set) { the_set }
      end
    end

    # Specify the file that should be used to bootstrap active plugins.
    #
    def activation_filename(filename)
      @activation_filename = filename
    end

    # Call this class method from a subclass to register an implementation with
    # the PluginSet.
    #
    def register
      plugin_set.register(self) do |p|
        yield p if block_given?
      end
    end

    # Activate selected plugins from a configuration file in the project's
    # root directory.
    #
    def activate
      plugin_set.activate(@activation_filename)
    end

    # Return the collection of registered plugins.
    #
    def known
      plugin_set.known
    end

    # Wipe known plugins.
    #
    def clear
      plugin_set.clear
    end

  end

end
