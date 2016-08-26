class ChangeNumEmployeesColumnOnOrganization < ActiveRecord::Migration
  def change
    change_column :organizations, :num_employees, :string
  end
end
