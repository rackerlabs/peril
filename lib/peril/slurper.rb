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
  end

end
