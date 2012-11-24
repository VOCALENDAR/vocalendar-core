class AddTimeZoneToEvent < ActiveRecord::Migration
  def change
    add_column :events, :timezone, :string, :default=>"Asia/Tokyo"
  end
end
