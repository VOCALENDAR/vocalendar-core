class Tag < ActiveRecord::Base
  has_many :tag_relations, :class_name => 'EventTagRelation'
  has_many :events, :through => :tag_relations
  has_and_belongs_to_many :calendars

  attr_accessible :name

  validates :name, :presence => true, :format => {:with => /^\S+$/}
end
