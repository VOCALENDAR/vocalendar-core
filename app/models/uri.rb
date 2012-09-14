class Uri < ActiveRecord::Base
  attr_accessible :event_id, :serviceName, :uri, :kind, :body
  belongs_to :event
end
