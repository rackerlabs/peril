class StringToText < ActiveRecord::Migration
  def up
    change_table :incidents do |t|
      t.change :url, :text, :limit => nil
      t.change :title, :text, :limit => nil
      t.change :extra, :text, :limit => nil
    end
  end

  def down
    change_table :incidents do |t|
      t.change :url, :string
      t.change :title, :string
      t.change :extra, :string
    end
  end
end
