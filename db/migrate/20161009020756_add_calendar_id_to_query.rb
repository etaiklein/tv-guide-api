class AddCalendarIdToQuery < ActiveRecord::Migration
  def change
    add_column :queries, :calendar_id, :integer
  end
end
