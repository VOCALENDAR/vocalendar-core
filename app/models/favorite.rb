class Favorite < ActiveRecord::Base

  belongs_to :event
  belongs_to :user

  attr_accessible :value
end
