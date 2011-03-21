class AddIsNewFlagToBadMessages < ActiveRecord::Migration
  def self.up
    add_column :bad_messages, :is_new, :boolean, :default => true
  end

  def self.down
    remove_column :bad_messages, :is_new
  end
end
