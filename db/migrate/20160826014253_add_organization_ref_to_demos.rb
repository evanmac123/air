class AddOrganizationRefToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :organization_id, :integer
    add_index  :demos, :organization_id
  end
end
