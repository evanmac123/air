class AddReplyToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :reply, :string, :default => "", :null => false
  end

  def self.down
    remove_column :rules, :reply
  end
end
