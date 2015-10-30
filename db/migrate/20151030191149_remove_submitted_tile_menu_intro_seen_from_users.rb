class RemoveSubmittedTileMenuIntroSeenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :submit_tile_intro_seen
  end

  def down
    add_column :users, :submit_tile_intro_seen, :boolean, default: false, null: false
  end
end
