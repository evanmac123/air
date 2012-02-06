class AddSuppressMuteNoticeFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suppress_mute_notice, :boolean, :default => false
  end

  def self.down
    remove_column :users, :suppress_mute_notice
  end
end
