class AddBizRoleIdentifiersToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_hrm, :boolean
    add_column :organizations, :roles, :string
  end
end
