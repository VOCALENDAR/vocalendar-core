class AddRecurInstanceInfoToEvent < ActiveRecord::Migration
  def change
    add_column :events, :g_recurring_event_id,      :string
    add_column :events, :recur_orig_start_date,     :date
    add_column :events, :recur_orig_start_datetime, :datetime
    add_index :events, [:g_recurring_event_id, :recur_orig_start_datetime], :name => 'idx_event_recur_info'
  end
end
