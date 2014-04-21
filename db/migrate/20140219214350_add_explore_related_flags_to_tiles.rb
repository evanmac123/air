class AddExploreRelatedFlagsToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :is_public, :boolean, default: false
    add_column :tiles, :is_copyable, :boolean, default: false

    add_index :tiles, :is_public
    add_index :tiles, :is_copyable
  end
end
