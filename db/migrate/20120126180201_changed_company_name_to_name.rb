class ChangedCompanyNameToName < ActiveRecord::Migration
  def self.up
    rename_column :demos, :company_name, :name
  end

  def self.down
    rename_column :demos, :name, :company_name
  end
end
