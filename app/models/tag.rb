class Tag < ActiveRecord::Base
  default_scope order('name')
  has_and_belongs_to_many :events

  attr_accessible :name, :is_category

  validates :name, :presence => true, :format => {:with => /^\S+$/}
end
