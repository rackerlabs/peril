require_relative 'pluggable'

module Peril

  # Continuously generates Events from some source.
  #
  class Slurper

    extend Pluggable

    activation_filename 'slurpers.rb'

    # Perform post-configuration setup for the Notifier instance.
    #
    def setup
    end

    # Check our source for new Events.
    #
    # @return [Array<Event>] Zero to many Event objects.
    #
    def next_events
      []
    end

    # Poll each registered Slurper for new events.
    #
    # @yieldparam e [Event] Each generated event.
    #
    def self.poll
      known.each do |slurper|
        slurper.next_events.each { |e| yield e }
      end
    end
  end

end
