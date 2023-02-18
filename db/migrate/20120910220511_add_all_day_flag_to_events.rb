class AddAllDayFlagToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :allday, :boolean, :null => false, :default => false
  end
end
