class AddQueriedAtToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :queried_at, :timestamp
  end
end
