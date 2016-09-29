# == Schema Information
#
# Table name: calendars
#
#  id         :integer          not null, primary key
#  url        :string           unique
#  ical       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Calendar < ActiveRecord::Base

  def update
    ical = WikiService.new({url: url}).create_calendar_of_episodes(true)
    save()
  end
end
