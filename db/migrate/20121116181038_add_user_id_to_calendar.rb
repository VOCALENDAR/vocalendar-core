class AddUserIdToCalendar < ActiveRecord::Migration
  def change
    add_column :calendars, :user_id, :integer
    add_index :calendars, :user_id
  end
end
