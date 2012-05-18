class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :calendar_id
      t.text :event
      t.text :etag
      t.text :status
      t.text :htmlLink
      t.text :summary
      t.text :description
      t.text :location

      t.timestamps
    end
  end
end
