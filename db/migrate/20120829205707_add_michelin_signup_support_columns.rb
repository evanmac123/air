class AddMichelinSignupSupportColumns < ActiveRecord::Migration
  def up
    add_column :users, :is_employee, :boolean, :default => true
    #add_column :users, :secondary_claim_code, :string
    add_index :users, :is_employee
    #add_index :users, :secondary_claim_code
  end

  def down
    remove_column :users, :secondary_claim_code
    remove_column :users, :is_employee
  end
end
