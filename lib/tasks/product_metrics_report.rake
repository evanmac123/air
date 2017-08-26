namespace :admin do
  namespace :reports do
    desc "Runs product KPI report"

    task :product_metrics_report => [:environment] do
      if Date.today == Date.today.end_of_week
        Reporting::ProductMetricsReportBuilder.build_week(to_date: Date.today).save

        Demo.paid_or_free_trial.each do |demo|
          Reporting::BoardHealthReportBuilder.build_week(board: demo, to_date: Date.today).save
        end
      end

      if Date.today == Date.today.end_of_month
        Reporting::ProductMetricsReportBuilder.build_month(to_date: Date.today).save

        Demo.paid_or_free_trial.each do |demo|
          Reporting::BoardHealthReportBuilder.build_month(board: demo, to_date: Date.today).save
        end
      end
    end
  end
end
