class AddReplyCounterCacheToBadMessage < ActiveRecord::Migration
  def self.up
    add_column :bad_messages, :reply_count, :integer, :default => 0
  end

  def self.down
    remove_column :bad_messages, :reply_count
  end
end
