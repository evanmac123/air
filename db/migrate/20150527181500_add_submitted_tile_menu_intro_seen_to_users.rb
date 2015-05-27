class AddSubmittedTileMenuIntroSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :submitted_tile_menu_intro_seen, :boolean, default: false, null: false
  end
end
