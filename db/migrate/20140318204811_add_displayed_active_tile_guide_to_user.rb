class AddDisplayedActiveTileGuideToUser < ActiveRecord::Migration
  def change
    add_column :users, :displayed_active_tile_guide, :boolean, default: false
  end
end
