# == Schema Information
#
# Table name: calendars
#
#  id         :integer          not null, primary key
#  url        :string
#  ical       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  queried_at :datetime
#

class Calendar < ActiveRecord::Base
  validates :ical, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates_length_of :ical, minimum: 120, too_short: 'please enter at least one event'
  has_many :queries, :foreign_key => 'calendar_id', :primary_key => 'id'

  def update
    ical = WikiService.new({url: url}).create_calendar_of_episodes(true)
  end
end
