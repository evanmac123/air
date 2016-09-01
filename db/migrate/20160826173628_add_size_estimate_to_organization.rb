class AddSizeEstimateToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :size_estimate, :string
  end
end
