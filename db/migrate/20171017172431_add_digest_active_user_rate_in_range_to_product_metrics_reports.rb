class AddDigestActiveUserRateInRangeToProductMetricsReports < ActiveRecord::Migration
  def change
    add_column :product_metrics_reports, :smb_digest_active_user_rate_in_range, :decimal
    add_column :product_metrics_reports, :enterprise_digest_active_user_rate_in_range, :string
  end
end
