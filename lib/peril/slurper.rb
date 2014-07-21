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

    # Configure a webhook to be invoked by Sinatra.
    #
    # @param block [Block] Configure routes with the normal Sinatra DSL.
    #
    def webhook(&block)
      @webhook = block
    end

    # Return the block configured by `webhook`, or an empty Proc if none was configured.
    #
    # @return [Block]
    def sinatra_hook
      @webhook || Proc.new {}
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

    # Register each `#webhook` block in a Sinatra application.
    #
    # @param sinatra [Sinatra::Base] A Sinatra application.
    #
    def self.install_webhooks(sinatra)
      known.each do |slurper|
        sinatra.instance_eval(&slurper.sinatra_hook)
      end
    end
  end

end
