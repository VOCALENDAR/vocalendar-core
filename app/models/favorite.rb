class Favorite < ApplicationRecord

  belongs_to :event, required: false
  belongs_to :user, required: false

  #attr_accessible :value
end
