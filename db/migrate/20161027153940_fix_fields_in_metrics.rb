class FixFieldsInMetrics < ActiveRecord::Migration
  def up
    remove_column :metrics, :posible_churn_customers
    rename_column :metrics, :cust_possible_churn, :possible_churn_customers 
  end

  def down

    add_column :metrics, :posible_churn_customers, :integer
    rename_column :metrics, :possible_churn_customers, :cust_possible_churn
  end
end
