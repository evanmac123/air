namespace :reports do
  namespace :internal do
    desc "Updates Client KPI Report"
    task client_kpi_report: :environment do
      puts "Updating total paid organization count..."
      Reporting::AirboTotals.set_total_paid_organizations

      puts "Updating total paid client admin count..."
      Reporting::AirboTotals.set_total_paid_client_admins

      [30, 60, 120, "current"].each { |n|
        puts "Updating percent eligible users joined for #{n} days..."
        Reporting::AirboTotals.set_percent_of_eligible_population_joined(n)
      }
    end
  end
end
