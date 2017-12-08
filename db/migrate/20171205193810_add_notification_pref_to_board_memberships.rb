class AddNotificationPrefToBoardMemberships < ActiveRecord::Migration
  def change
    add_column :board_memberships, :notification_pref_cd, :integer, default: 0
  end
end
