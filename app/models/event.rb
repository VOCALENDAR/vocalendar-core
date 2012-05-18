class Event < ActiveRecord::Base
  attr_accessible :calendar_id, :description, :etag, :event, :htmlLink, :location, :status, :summary
end
