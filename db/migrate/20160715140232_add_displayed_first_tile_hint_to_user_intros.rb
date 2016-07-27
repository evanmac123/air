class AddDisplayedFirstTileHintToUserIntros < ActiveRecord::Migration
  def change
    remove_column :users, :displayed_first_tile_hint
    add_column :user_intros, :displayed_first_tile_hint, :boolean, :default => false
  end
end
