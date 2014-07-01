require_relative 'pluggable'

module Peril

  # Performs some form of notification after a new Event has been received.
  #
  class Notifier

    extend Pluggable

    activation_filename 'notifications.rb'

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

  end

end
