class AddOrganizationIndexToDemos < ActiveRecord::Migration
  def change
    add_index  :demos, :organization_id
  end
end
