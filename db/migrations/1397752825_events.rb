class Events < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string :unique_id
      t.string :reporter

      t.string :url
      t.string :title
      t.string :tags

      t.string :assignee
      t.timestamp :assigned_at
      t.timestamp :completed_at

      t.string :extra
    end
  end

  def down
    drop_table :events
  end
end
