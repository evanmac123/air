class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.integer :starting_customers
      t.integer :added_customers
      t.integer :cust_possible_churn
      t.integer :cust_churned
      t.decimal :starting_mrr
      t.decimal :added_mrr
      t.decimal :new_cust_mrr
      t.decimal :upgrade_mrr
      t.decimal :possible_churn_mrr
      t.decimal :churned_mrr
      t.decimal :churned_mrr
      t.float :percent_churned_mrr
      t.float :net_churned_mrr
      t.timestamps
    end
  end
end
