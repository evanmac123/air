class AddOrganizationToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :organization_id, :integer
  end
end
