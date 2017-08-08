class AddIsSiteAdminIndexToUsers < ActiveRecord::Migration
  def change
    add_index(:users, :is_site_admin)
  end
end
