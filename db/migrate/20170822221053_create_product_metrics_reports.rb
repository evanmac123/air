class CreateProductMetricsReports < ActiveRecord::Migration
  def change
    create_table :product_metrics_reports do |t|
      t.date :from_date
      t.date :to_date
      t.integer :period_cd, default: 0
      t.integer :smb_tiles_delivered
      t.decimal :smb_overall_completion_rate
      t.decimal :smb_completion_rate_in_range
      t.decimal :smb_overall_view_rate
      t.decimal :smb_view_rate_in_range
      t.decimal :smb_percent_orgs_posted
      t.decimal :smb_percent_orgs_activity
      t.decimal :smb_percent_orgs_copied
      t.integer :enterprise_tiles_delivered
      t.decimal :enterprise_overall_completion_rate
      t.decimal :enterprise_completion_rate_in_range
      t.decimal :enterprise_overall_view_rate
      t.decimal :enterprise_view_rate_in_range
      t.decimal :enterprise_percent_orgs_posted
      t.decimal :enterprise_percent_orgs_activity
      t.decimal :enterprise_percent_orgs_copied
      t.timestamps
    end
  end
end
