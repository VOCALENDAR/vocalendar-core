class DropRecurAttrsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :recur_freq
    remove_column :events, :recur_count
    remove_column :events, :recur_until
    remove_column :events, :recur_interval
    remove_column :events, :recur_wday
  end

  def down
    add_column :events, :recur_freq,     :string
    add_column :events, :recur_count,    :integer, :default => 0, :null => false
    add_column :events, :recur_until,    :string
    add_column :events, :recur_interval, :integer, :default => 1, :null => false
    add_column :events, :recur_wday      :string
  end
end
