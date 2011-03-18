class AddForeignKeyIndicesOnBadMessageStuff < ActiveRecord::Migration
  def self.up
    add_index :bad_messages, :user_id
    add_index :bad_messages, :thread_id
    add_index :bad_message_replies, :bad_message_id
    add_index :bad_message_replies, :sender_id
  end

  def self.down
    remove_index :bad_message_replies, :column => :sender_id
    remove_index :bad_message_replies, :column => :bad_message_id
    remove_index :bad_messages, :column => :thread_id
    remove_index :bad_messages, :column => :user_id
  end
end
