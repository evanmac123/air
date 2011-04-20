class AddAutomatedReplyToBadMessage < ActiveRecord::Migration
  def self.up
    add_column :bad_messages, :automated_reply, :string, :limit => 160, :null => false, :default => ''
  end

  def self.down
    remove_column :bad_messages, :automated_reply
  end
end
