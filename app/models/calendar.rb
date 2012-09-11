class Calendar < ActiveRecord::Base
  attr_accessible :name, :external_id, :synced_at
end

class SourceCalendar < Calendar
end

class DestCalendar < Calendar
end
