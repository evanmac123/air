class AddIsSharableToTile < ActiveRecord::Migration
  def change
  	add_column :tiles, :is_sharable, :boolean
  	execute "UPDATE tiles SET is_sharable = 'true' WHERE is_public = 'true'"
  end
end
