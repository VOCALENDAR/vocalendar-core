class Tag < ActiveRecord::Base
  default_scope order('name')
  has_and_belongs_to_many :events
  has_and_belongs_to_many :calendars

  attr_accessible :name

  validates :name, :presence => true, :format => {:with => /^\S+$/}
end
