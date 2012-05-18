class Calendar < ActiveRecord::Base
  attr_accessible :calendar, :name
  has_many :events
end
