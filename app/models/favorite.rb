class Favorite < ApplicationRecord

  belongs_to :event
  belongs_to :user

  #attr_accessible :value
end
