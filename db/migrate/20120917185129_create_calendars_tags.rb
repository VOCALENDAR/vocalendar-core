class CreateCalendarsTags < ActiveRecord::Migration
  def change
    create_table :calendars_tags, :id => false do |t|
      t.integer :calendar_id
      t.integer :tag_id
    end
  end
end
