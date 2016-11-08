class AddCurrentMrrToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :current_mrr, :decimal
  end
end
