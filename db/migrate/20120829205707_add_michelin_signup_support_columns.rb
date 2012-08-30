class AddMichelinSignupSupportColumns < ActiveRecord::Migration
  def up
    add_column :users, :is_employee, :boolean, :default => true
    add_index :users, :is_employee
  end

  def down
    remove_column :users, :is_employee
  end
end
