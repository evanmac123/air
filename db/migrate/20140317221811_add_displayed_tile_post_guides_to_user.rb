class AddDisplayedTilePostGuidesToUser < ActiveRecord::Migration
  def change
    add_column :users, :displayed_tile_post_guide, :boolean, default: false
    add_column :users, :displayed_tile_success_guide, :boolean, default: false
  end
end
