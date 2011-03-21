class AddWatchListFlagToBadMessage < ActiveRecord::Migration
  def self.up
    add_column :bad_messages, :on_watch_list, :boolean, :default => false
    add_index :bad_messages, :phone_number
  end

  def self.down
    remove_index :bad_messages, :column => :phone_number
    remove_column :bad_messages, :on_watch_list
  end
end
