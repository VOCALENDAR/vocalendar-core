class UpdateCalendarAttributes < ActiveRecord::Migration[5.1]
  def up
    remove_column :calendars, :calendar
    change_column :calendars, :name, :string, :null => false, :default => ''
    add_column :calendars, :external_id, :string, :null => false, :default => ''
    add_column :calendars, :synced_at, :datetime
    add_column :calendars, :type, :string

    add_index :calendars, :external_id
    add_index :calendars, :type
  end

  def down
    remove_index :calendars, :external_id
    remove_index :calendars, :type

    remove_column :calendars, :external_id
    remove_column :calendars, :synced_at
    remove_column :calendars, :type
    change_column :calendars, :name, :text, :null => true, :default => nil
    add_column :calendars, :calendar, :text
  end
end
