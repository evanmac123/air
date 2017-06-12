class AddChartMogulUuids < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :chart_mogul_uuid, :text
    add_column :organizations, :chart_mogul_uuid, :text
    add_column :invoices, :chart_mogul_uuid, :text
  end
end
