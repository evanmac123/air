class AddEmployeeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :employee_id, :string
    add_index :users, :employee_id
  end
end
