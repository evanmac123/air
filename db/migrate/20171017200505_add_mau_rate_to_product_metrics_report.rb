class AddMauRateToProductMetricsReport < ActiveRecord::Migration
  def change
    add_column :product_metrics_reports, :smb_mau_rate, :decimal
    add_column :product_metrics_reports, :enterprise_mau_rate, :decimal
  end
end
