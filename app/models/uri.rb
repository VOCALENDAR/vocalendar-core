class Uri < ActiveRecord::Base
  attr_accessible :body, :event_id, :kind, :serviceName, :uri
  belongs_to :event
end
