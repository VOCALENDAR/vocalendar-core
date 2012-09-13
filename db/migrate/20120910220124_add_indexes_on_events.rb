class AddIndexesOnEvents < ActiveRecord::Migration
  def change
    add_index :events, [:start_datetime, :status]
    add_index :events, [:end_datetime, :status]
    add_index :events, :g_calendar_id
    add_index :events, [:updated_at, :status]
    add_index :events, :etag
    add_index :events, :status
    add_index :events, :g_id
  end
end
