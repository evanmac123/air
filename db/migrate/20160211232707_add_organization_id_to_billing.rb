class AddOrganizationIdToBilling < ActiveRecord::Migration
  def change
    add_column :billings, :organization_id, :integer
  end
end
