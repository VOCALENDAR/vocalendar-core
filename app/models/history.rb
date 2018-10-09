class History < ApplicationRecord
  default_scope ->{ order('created_at desc') }
  belongs_to :user, required: false
  # rails 4 chenge strong_parameters
  #attr_accessible :action, :note, :target, :target_id, :target_type, :user_id

  validates :target, :presence => true
  validates :action, :presence => true
end
