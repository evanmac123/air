class AddFollowUpMessageSentAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :follow_up_message_sent_at, :timestamp
    execute "UPDATE users SET follow_up_message_sent_at = accepted_invitation_at"
  end

  def self.down
    remove_column :users, :follow_up_message_sent_at
  end
end
