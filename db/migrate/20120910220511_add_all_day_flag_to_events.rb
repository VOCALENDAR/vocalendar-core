class AddAllDayFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :allday, :boolean, :null => false, :default => false
  end
end
