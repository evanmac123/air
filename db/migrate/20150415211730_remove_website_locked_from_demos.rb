class RemoveWebsiteLockedFromDemos < ActiveRecord::Migration
  def up
    remove_column :demos, :website_locked
  end

  def down
    add_column :demos, :website_locked, :boolean, default: false
  end
end
