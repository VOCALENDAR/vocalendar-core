class EventTagRelation < ActiveRecord::Base
  belongs_to :event
  belongs_to :tag
  attr_accessible :event_id, :order, :tag_id, :target_field, :uri
end
