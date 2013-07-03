class AddWebsiteLockedFlagToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :website_locked, :boolean, default: false
  end
end
