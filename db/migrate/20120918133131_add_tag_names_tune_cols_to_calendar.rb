class AddTagNamesTuneColsToCalendar < ActiveRecord::Migration
  def change
    add_column :calendars, :tag_names_append_str, :string
    add_column :calendars, :tag_names_remove_str, :string
  end
end
