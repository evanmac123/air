class AddHasOwnTileCompletedColumns < ActiveRecord::Migration
  def change
    add_column :users, :has_own_tile_completed_displayed, :boolean, default: false
    add_column :users, :has_own_tile_completed_id, :integer
  end
end
