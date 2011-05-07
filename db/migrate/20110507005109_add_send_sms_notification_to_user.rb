class AddSendSmsNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :send_follow_notification_sms, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :send_follow_notification_sms
  end
end
