class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.text :kind
      t.text :calendar_id
      t.text :event
      t.text :etag
      t.text :status
      t.text :htmlLink
      t.text :summary
      t.text :description
      t.text :location
      t.text :colorId
      t.text :creatorEmail
      t.text :creatorDisplayName
      t.date :startDate
      t.datetime :startDateTime
      t.text :startTimeZone
      t.date :endDate
      t.datetime :endDateTime
      t.text :endTimeZone
      t.datetime :created
      t.datetime :updated

      t.timestamps
    end
  end
end
