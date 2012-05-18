class Event < ActiveRecord::Base
  attr_accessible :calendar_id, :description, :etag, :event, :htmlLink, :location, :status, :summary, :kind, :colorId, :creatorEmail, :creatorDisplayName, :startDate, :startDateTime, :startTimeZone, :endDate, :endDateTime, :endTimeZone, :created, :updated
  belongs_to :calendar
  has_many :uris
end
