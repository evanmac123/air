class AddCustChurnedToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :cust_churned, :integer
    add_column :metrics, :cust_possible_churn, :integer
  end
end
