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
    has_many :events

    # Non-ActiveRecord attributes.
    attr_accessor :just_created, :just_updated

    def assigned?
      assignee && assigned_at && completed_at.nil?
    end

    def completed?
      !! completed_at
    end

    def just_created? ; @just_created ; end

    def just_updated? ; @just_updated ; end

    # Find or create an Incident that maps to the `unique_id` specified by
    # an Event. Populate or update it based on the event's context and add
    # the Event to its `#events` relation.
    #
    # @param e [Event] New information.
    #
    def self.for_event(e)
      created = false
      i = find_or_create_by(unique_id: e.unique_id) do |n|
        n.original_reporter = e.reporter
        created = true
      end

      i = create_with(original_reporter: e.reporter).
        find_or_create_by(unique_id: e.unique_id)

      %i{url title tags assignee assigned_at completed_at extra}.each do |attr|
        i.send("#{attr}=", e.send(attr))
      end

      i.events << e
      i.save!

      i.just_created = created
      i.just_updated = ! created

      i
    end
  end

end
