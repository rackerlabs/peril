class MissedUniqueId < ActiveRecord::Migration
  INCIDENT_ATTRS = %i{unique_id tags original_reporter assignee}
  EVENT_ATTRS = %i{unique_id reporter url title tags assignee extra}

  def up
    change_table :incidents do |t|
      INCIDENT_ATTRS.each do |attr|
        t.change attr, :text, :limit => nil
      end
    end

    change_table :events do |t|
      EVENT_ATTRS.each do |attr|
        t.change attr, :text, :limit => nil
      end
    end
  end

  def down
    change_table :incidents do |t|
      INCIDENT_ATTRS.each do |attr|
        t.change attr, :string
      end
    end

    change_table :events do |t|
      EVENT_ATTRS.each do |attr|
        t.change attr, :string
      end
    end
  end
end
