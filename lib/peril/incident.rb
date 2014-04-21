module Peril

  # An Incident is the latest known state of a support thread, based on the
  # stream of Events.
  #
  class Incident < ActiveRecord::Base
  end

end
