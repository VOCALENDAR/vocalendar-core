class EventTagRelation < ActiveRecord::Base
  belongs_to :event
  belongs_to :tag
  attr_accessible :event_id, :pos, :tag_id, :target_field
end
