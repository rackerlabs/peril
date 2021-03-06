module Peril


  # Schema:
  #
  # ```
  # t.text :unique_id
  # t.text :reporter
  # t.integer :incident_id
  #
  # t.text :url
  # t.text :title
  # t.text :tags
  #
  # t.text :assignee
  # t.timestamp :assigned_at
  # t.timestamp :completed_at
  #
  # t.text :extra
  #
  # t.timestamp :created_at
  # t.timestamp :updated_at
  # ```
  #
  class Event < ActiveRecord::Base
    belongs_to :incident

    validates :reporter, :unique_id, presence: true

    def assignment?
      assignee && assigned_at && completed_at.nil?
    end

    def completion?
      !! completed_at
    end

    def self.from_h(hash)
      # Stringify the keys first, so I can use symbols in unit tests, but JSON can
      # give me Strings instead.
      hash.keys.each { |k| hash[k.to_s] = hash[k] }

      new do |e|
        e.unique_id = hash['unique_id']
        e.reporter = hash['reporter']
        e.url = hash['url']
        e.title = hash['title']
        e.tags = hash['tags'].join(',') if hash['tags']

        e.assignee = hash['assignee']
        e.assigned_at = hash['assigned_at']

        e.completed_at = hash['completed_at']

        e.assigned_at = Time.now if e.assignee && ! e.assigned_at

        # Derive a missing unique_id from other fields if possible.
        if e.unique_id.nil?
          case
          when e.url
            e.unique_id = e.url
          when e.title && e.reporter
            e.unique_id = "#{e.reporter}:title:#{e.title}"
          when hash['origin_id'] && e.reporter
            e.unique_id = "#{e.reporter}:origin:#{hash['origin_id']}"
          end
        end

        # Derive a missing title from other fields if possible.
        if e.title.nil?
          case
          when e.url
            e.title = e.url
          when hash['origin_id'] && e.reporter
            e.title = "#{e.reporter} #{hash['origin_id']}"
          end
        end
      end
    end
  end

end
