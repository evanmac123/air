class AddsAnswerIdxToTileUserNotifications < ActiveRecord::Migration
  def up
    add_column :tile_user_notifications, :answer_idx, :integer
    remove_column :tile_user_notifications, :answer
  end

  def down
    remove_column :tile_user_notifications, :answer_idx
    add_column :tile_user_notifications, :answer, :string
  end
end
