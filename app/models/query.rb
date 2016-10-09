# == Schema Information
#
# Table name: queries
#
#  id          :integer          not null, primary key
#  query       :string           not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  calendar_id :integer
#

class Query < ActiveRecord::Base
  has_one :calendar, :foreign_key => 'id', :primary_key => 'calendar_id'
end
