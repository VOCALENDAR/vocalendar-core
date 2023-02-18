class AddIndexOnCalendarsTags < ActiveRecord::Migration[5.1]
  def change
    add_index :calendars_tags, :tag_id
    add_index :calendars_tags, :calendar_id
  end
end
