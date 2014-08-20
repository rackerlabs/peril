class TimestampEverything < ActiveRecord::Migration
  def change
    %i{incidents events}.each do |tablename|
      change_table(tablename) { |t| t.timestamps }
    end
  end
end
