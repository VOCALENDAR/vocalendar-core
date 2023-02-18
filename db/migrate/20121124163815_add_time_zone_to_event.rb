class AddTimeZoneToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :timezone, :string, :default=>"Asia/Tokyo"
  end
end
