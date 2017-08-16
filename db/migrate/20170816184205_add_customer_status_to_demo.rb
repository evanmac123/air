class AddCustomerStatusToDemo < ActiveRecord::Migration
  def up
    add_column :demos, :customer_status_cd, :integer, default: 0
    remove_column :demos, :join_type
  end

  def down
    remove_column :demos, :customer_status_cd
  end
end
