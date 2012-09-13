class Calendar < ActiveRecord::Base
  attr_accessible :name, :external_id, :synced_at, :io_type
end
