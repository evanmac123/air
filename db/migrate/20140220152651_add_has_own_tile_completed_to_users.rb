class AddHasOwnTileCompletedToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :has_own_tile_completed, :boolean, default: false
  end
end
