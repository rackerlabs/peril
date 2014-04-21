module Peril

  # An Incident is the latest known state of a support thread, based on the
  # stream of Events.
  #
  # Schema:
  #
  # ```
  # t.string :unique_id
  # t.string :original_reporter
  #
  # t.string :url
  # t.string :title
  # t.string :tags
  #
  # t.string :assignee
  # t.timestamp :assigned_at
  # t.timestamp :completed_at
  #
  # t.string :extra
  # ```
  #
  class Incident < ActiveRecord::Base
  end

end
