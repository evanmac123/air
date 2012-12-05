class AddClientAdminFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_client_admin, :boolean, :default => false
  end
end
