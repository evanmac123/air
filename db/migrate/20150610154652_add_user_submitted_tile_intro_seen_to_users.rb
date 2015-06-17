class AddUserSubmittedTileIntroSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_submitted_tile_intro_seen, :boolean, default: false, null: false
  end
end
