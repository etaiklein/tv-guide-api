class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :url, unique: true
      t.string :ical
      t.string :title

      t.timestamps null: false
    end
  end
end
