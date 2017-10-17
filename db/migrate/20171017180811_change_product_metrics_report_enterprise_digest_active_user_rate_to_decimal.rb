class ChangeProductMetricsReportEnterpriseDigestActiveUserRateToDecimal < ActiveRecord::Migration
  def up
    remove_column :product_metrics_reports, :enterprise_digest_active_user_rate_in_range
    add_column :product_metrics_reports, :enterprise_digest_active_user_rate_in_range, :decimal
  end

  def down
  end
end
