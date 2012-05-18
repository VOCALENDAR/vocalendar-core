class CreateUris < ActiveRecord::Migration
  def change
    create_table :uris do |t|
      t.text :event_id
      t.text :serviceName
      t.text :uri
      t.text :kind
      t.text :body

      t.timestamps
    end
  end
end
