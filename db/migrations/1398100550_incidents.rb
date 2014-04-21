class Incidents < ActiveRecord::Migration
  def up
    create_table :incidents do |t|
      t.string :unique_id
      t.string :original_reporter

      t.string :url
      t.string :title
      t.string :tags

      t.string :assignee
      t.timestamp :assigned_at
      t.timestamp :completed_at

      t.string :extra
    end

    change_table :events do |t|
      t.integer :incident_id
    end
  end

  def down
    drop_table :incidents

    change_table :events do |t|
      t.remove :incident_id
    end
  end
end
