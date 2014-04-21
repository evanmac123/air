class AddOriginalCreatedAtToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :original_created_at, :timestamp
  end
end
