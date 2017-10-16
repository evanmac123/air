namespace :admin do
  namespace :reports do
    desc "Runs product KPI report"

    task :product_metrics_report => [:environment] do
      puts "Running Product Metrics Monthly Report"
      Reporting::ProductMetricsReportBuilder.build_month(to_date: Date.today.end_of_month).save

      if 8.days.ago.month != Data.today.month
        Reporting::ProductMetricsReportBuilder.build_month(to_date: 1.month.ago.end_of_month).save
      end

      puts "Running Product Metrics Board Health Reports for current Month"
      Demo.paid_or_free_trial.each do |demo|
        Reporting::BoardHealthReportBuilder.build_month(board: demo, to_date: Date.today.end_of_month).save
      end

      if Date.today == Date.today.end_of_week
        puts "Running Product Metrics Weekly Report"
        Reporting::ProductMetricsReportBuilder.build_week(to_date: Date.today.end_of_week).save

        puts "Running Product Metrics Board Health Reports for Week"
        Demo.paid_or_free_trial.each do |demo|
          Reporting::BoardHealthReportBuilder.build_week(board: demo, to_date: Date.today.end_of_week).save
        end
      end
    end
  end
end
