class AddFieldsToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :downgrade_mmr, :decimal
    add_column :metrics, :churned_customer_mrr, :decimal
    add_column :metrics, :net_changed_mrr, :decimal
    add_column :metrics, :net_change_customers, :integer
    add_column :metrics, :current_customers, :integer
    add_column :metrics, :percent_churned_customers, :float
  end
end
