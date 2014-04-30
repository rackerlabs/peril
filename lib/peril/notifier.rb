module Peril

  # Performs some form of notification after a new Event has been received.
  #
  class Notifier

    # Perform post-configuration setup for the Notifier instance.
    #
    def setup
    end

    # Handle an incoming Event and the Incident it was resolved to.
    #
    # @param event [Event] The Event that was just received.
    # @param incident [Incident] The Incident that has been created or updated
    #   with its contents.
    #
    def process(event, incident)
    end

    # Pass an `event` and `incident` to all registered `Notifiers`.
    #
    # @see process
    #
    def self.handle(event, incident)
      known.each { |n| n.process event, incident }
    end

    # Load the `notifications.rb` or `notifications.rb.example` file to
    # activate and configure Notifier subclasses.
    #
    def self.activate
      %w{notifications.rb notifications.rb.example}.each do |path|
        full_path = File.join Config::ROOT, path
        if File.exist?(full_path)
          load full_path
          return
        end
      end

      raise RuntimeError.new('Unable to configure active Notifiers.')
    end

    # The collection of `registered` Notifier subclass instances.
    #
    def self.known
      @known ||= []
    end

    # Reset the collection of known Notifiers. Most useful in specs.
    #
    def self.clear
      @known = []
    end

    # Register a subclass as a known Notifier. If a block is given, it can be
    # used to customize the new instance.
    #
    # @yieldparam n [Notifier] The newly instantiated Notifier subclass before
    #   it's added to `known`.
    #
    def self.register
      n = new
      yield n if block_given?
      n.setup
      Notifier.known << n
    end
  end

end
