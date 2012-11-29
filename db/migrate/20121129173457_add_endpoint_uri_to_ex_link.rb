class AddEndpointUriToExLink < ActiveRecord::Migration
  def change
    add_column :ex_links, :endpoint_uri, :text
  end
end
