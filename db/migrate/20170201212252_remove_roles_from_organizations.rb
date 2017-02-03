class RemoveRolesFromOrganizations < ActiveRecord::Migration
  def up
    remove_column :organizations, :roles
  end

  def down
    add_column :organizations, :roles, :string
  end
end
