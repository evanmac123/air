class AddDisplayedFirstTileHintToUsers < ActiveRecord::Migration
  def change
    add_column :users, :displayed_first_tile_hint, :boolean, :default => false
  end
end
