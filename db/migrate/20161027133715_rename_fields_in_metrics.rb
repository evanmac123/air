class RenameFieldsInMetrics < ActiveRecord::Migration
  def up
    rename_column :metrics, :cust_churned, :churned_customers
    rename_column :metrics, :cust_possible_churn, :posible_churn_customers
  end

  def down

    rename_column :metrics, :churned_customers, :cust_churned
    rename_column :metrics, :posible_churn_customers, :cust_possible_churn
  end
end
