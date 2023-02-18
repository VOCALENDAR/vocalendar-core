class StopToUseStIonCalendar < ActiveRecord::Migration[5.1]
  def up
    rename_column :calendars, :type, :io_type
    change_column :calendars, :io_type, :string, :null => false, :default => ''
  end

  def down
    rename_column :calendars, :io_type, :type
    change_column :calendars, :type, :string
  end
end
