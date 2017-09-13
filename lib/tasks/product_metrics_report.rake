namespace :admin do
  namespace :reports do
    desc "Runs product KPI report"

    task :product_metrics_report => [:environment] do
      puts "Running Product Metrics Monthly Report"
      Reporting::ProductMetricsReportBuilder.build_month(to_date: Date.today.end_of_month).save

      if Date.today == Date.today.end_of_week
        puts "Running Product Metrics Weekly Report"
        Reporting::ProductMetricsReportBuilder.build_week(to_date: Date.today.end_of_week).save

        puts "Running Product Metrics Board Health Reports for Week"
        Demo.paid_or_free_trial.each do |demo|
          Reporting::BoardHealthReportBuilder.build_week(board: demo, to_date: Date.today.end_of_week).save
        end
      end

      if Date.today == Date.today.end_of_month
        puts "Running Product Metrics Board Health Reports for Month"
        Demo.paid_or_free_trial.each do |demo|
          Reporting::BoardHealthReportBuilder.build_month(board: demo, to_date: Date.today.end_of_month).save
        end
      end
    end
  end
end
