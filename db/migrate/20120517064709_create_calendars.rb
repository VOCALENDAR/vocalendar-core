class CreateCalendars < ActiveRecord::Migration[5.1]
  def change
    create_table :calendars do |t|
      t.text :calendar
      t.text :name

      t.timestamps
    end
  end
end
