task prep_data_for_product_kpis: :environment do
  Subscription.all.each { |s| s.save }

  [*1..4].each do |n|
    report = Reporting::ProductMetricsReportBuilder.build_month(from_date: n.month.ago.beginning_of_month)

    report.save
  end

  [*1..20].each do |n|
    report = Reporting::ProductMetricsReportBuilder.build_week(from_date: n.week.ago.beginning_of_week)

    report.save
  end
end
