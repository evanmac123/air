class AddActivatedAndArchivedTimesToTiles < ActiveRecord::Migration

  # From the Rails Guides: http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  # A fix for this is to create a local model within the migration. This keeps Rails from running the validations,
  # so that the migrations run to completion.
  # When using a local model, it's a good idea to call Tile.reset_column_information to refresh the
  # ActiveRecord cache for the Tile model prior to updating data in the database.

  class Tile < ActiveRecord::Base
  end

  def up
    add_column :tiles, :activated_at, :datetime
    add_column :tiles, :archived_at,  :datetime

    Tile.reset_column_information

    Tile.all.each { |tile| tile.update_attributes activated_at: tile.created_at, archived_at: tile.created_at }
  end

  def down
    remove_column :tiles, :activated_at
    remove_column :tiles, :archived_at
  end
end
