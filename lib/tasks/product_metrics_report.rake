namespace :admin do
  namespace :reports do
    desc "Runs product KPI report"

    task :product_metrics_report => [:environment] do
      Reporting::ProductMetricsReportBuilder.run
    end
  end
end
