task rerun_product_metrics: :environment do
  ProductMetricsReport.where({ period_cd: ProductMetricsReport.periods[:month] }).delete_all

  [6.months.ago, 5.months.ago, 4.months.ago, 3.months.ago, 2.months.ago, 1.month.ago, Date.today].each do |d|
    Reporting::ProductMetricsReportBuilder.build_month(date: d.end_of_month.to_date).save
  end
end

task product_metrics_add_view_mau: :environment do
  ProductMetricsReport.where({ period_cd: ProductMetricsReport.periods[:month] }).each do |pr|
    pr.enterprise_mau_rate = pr.mau_completion_rate(scope: pr.send(:enterprise_tiles_digests_in_range))

    pr.smb_mau_rate = pr.mau_completion_rate(scope: pr.send(:smb_tiles_digests_in_range))

    pr.save
  end
end
