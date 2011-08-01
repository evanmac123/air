class AddSiteAdminFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_site_admin, :boolean, :default => false
    change_column_null :users, :is_site_admin, false, false
  end

  def self.down
    remove_column :users, :is_site_admin
  end
end
