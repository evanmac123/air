class AddSubmitTileIntroSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :submit_tile_intro_seen, :boolean, default: false, null: false
  end
end
