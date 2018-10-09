class EventTagRelation < ApplicationRecord
  belongs_to :event, required: false
  belongs_to :tag, required: false

  #attr_accessible :event_id, :pos, :tag_id, :target_field

  scope :order_target_field_pos, -> { order(:target_field, :pos) }

end
