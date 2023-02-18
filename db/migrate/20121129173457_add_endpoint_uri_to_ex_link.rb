class AddEndpointUriToExLink < ActiveRecord::Migration[5.1]
  def change
    add_column :ex_links, :endpoint_uri, :text
  end
end
