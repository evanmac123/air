namespace :reports do
  namespace :internal do
    desc "Builds Client KPI Reports"
    task client_kpi_report: :environment do
      Reporting::ClientKPIReport.run_report
    end
  end
end
