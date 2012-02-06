class AddUserMutedAtAndUserLastToldAboutMuteAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_muted_at, :timestamp
    add_column :users, :last_told_about_mute, :timestamp
    add_column :users, :mt_texts_today, :integer
    execute("UPDATE users SET mt_texts_today=0")
    change_column :users, :mt_texts_today, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :mt_texts_today
    remove_column :users, :last_told_about_mute
    remove_column :users, :last_muted_at
  end
end
