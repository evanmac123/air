class RemoveUserIdFromBadMessagesAndIndexUserPhoneNumber < ActiveRecord::Migration
  def self.up
    remove_column :bad_messages, :user_id
    add_index :users, :phone_number
  end

  def self.down
    remove_index :users, :column => :phone_number
    add_column :bad_messages, :user_id
  end
end
