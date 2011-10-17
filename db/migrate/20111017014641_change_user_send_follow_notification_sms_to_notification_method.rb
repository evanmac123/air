class ChangeUserSendFollowNotificationSmsToNotificationMethod < ActiveRecord::Migration
  def self.up
    add_column :users, :notification_method, :string
    execute "UPDATE users SET notification_method = 'sms' WHERE send_follow_notification_sms = true"
    execute "UPDATE users SET notification_method = 'none' WHERE send_follow_notification_sms = false"
    remove_column :users, :send_follow_notification_sms
    change_column :users, :notification_method, :string, :null => false, :default => "both"
  end

  def self.down
    add_column :users, :send_follow_notification_sms, :boolean
    execute "UPDATE users SET send_follow_notification_sms = true WHERE notification_method = 'sms' OR notification_method = 'both'"
    execute "UPDATE users SET send_follow_notification_sms = false WHERE send_follow_notification_sms IS NULL"
    remove_column :users, :notification_method
    change_column :users, :send_follow_notification_sms, :boolean, :null => false, :default => true
  end
end
