class AddLoginAnnouncementToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :login_announcement, :string
  end

  def self.down
    remove_column :demos, :login_announcement
  end
end
