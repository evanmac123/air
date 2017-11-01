task rerun_product_metrics: :environment do
  ProductMetricsReport.where({ period_cd: ProductMetricsReport.periods[:month] }).delete_all

  [6.months.ago, 5.months.ago, 4.months.ago, 3.months.ago, 2.months.ago, 1.month.ago, Date.today].each do |d|
    Reporting::ProductMetricsReportBuilder.build_month(date: d.end_of_month.to_date).save
  end
end
