class AddCompanySizeToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :company_size_cd, :integer, default: 0
    remove_column :organizations, :sales_channel
    remove_column :organizations, :churn_reason
    remove_column :organizations, :size_estimate
  end

  def down
    remove_column :organizations, :company_size_cd
  end
end
