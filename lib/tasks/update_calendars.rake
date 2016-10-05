desc 'update calendars'
task update_calendars: :environment do
  Calendar.all.map {|c| c.update}
end