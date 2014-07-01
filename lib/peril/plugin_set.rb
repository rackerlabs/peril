module Peril

  # Collection of loaded plugins of a specific type.
  #
  class PluginSet
    attr_reader :known

    # Create a new, empty set of plugins.
    #
    # @param klass [Class] Plugin instance implementation kind.
    #
    def initialize(klass)
      @klass = klass
      @known = []
    end

    # Load the first candidate file that's present to activate and configure
    # plugin instances.
    #
    # @param basename [String] The activation file to search for. If the file
    #   with this exact name doesn't exist, basename.example will be loaded
    #   instead.
    # @raises RuntimeError if neither the activation file or the example file
    #   exist.
    #
    def activate(basename)
      [basename, "#{basename}.example"].each do |path|
        full_path = File.join Config::ROOT, path
        if File.exist?(full_path)
          load full_path
          return
        end
      end

      raise RuntimeError.new("Unable to configure active #{@klass.name}.")
    end
  end

  # Reset the collection of activated plugins. Most useful in specs.
  #
  def clear
    @known = []
  end

  # Register a plugin instance. If a block is given, it can be used to customize
  # the new instance.
  #
  # @yieldparam p [Plugin] The newly instantiated plugin subclass before
  #   it's added to `known`.
  #
  def register(subclass)
    p = subclass.new
    yield p
    p.setup
    @known << p
  end
end
