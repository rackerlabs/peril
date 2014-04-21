module Peril

  # Performs some form of notification after a new Event has been received.
  #
  class Notifier

    # Handle an incoming Event and the Incident it was resolved to.
    #
    # @param event [Event] The Event that was just received.
    # @param incident [Incident] The Incident that has been created or updated
    #   with its contents.s
    #
    def process(event, incident)
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
      Notifier.known << n
    end
  end

end
