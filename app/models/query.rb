class Query < ActiveRecord::Base
  has_one :calendar, :foreign_key => 'query', :primary_key => 'url'
end
