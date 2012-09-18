class AddLatestSyncItemUpdatedAtToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :latest_synced_item_updated_at, :datetime
    rename_column :calendars, :synced_at, :sync_started_at
    add_column :calendars, :sync_finished_at, :datetime
  end
end
