class EventTagRelation < ApplicationRecord
  belongs_to :event
  belongs_to :tag

  #attr_accessible :event_id, :pos, :tag_id, :target_field

  scope :order_target_field_pos, -> { order(:target_field, :pos) }

end
