class AddUrlIndexToCalendars < ActiveRecord::Migration
  def change
    add_index :calendars, :url
  end
end
