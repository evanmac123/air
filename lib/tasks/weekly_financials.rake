namespace :admin do
  namespace :reports do
    namespace :financials do

      desc "Runs the weekly/monthly up to date Financials report"
      task :build_daily => [:environment, :renewals] do
          FinancialKpiBuilder.build_current_week
          FinancialKpiBuilder.build_current_month
      end

      desc "Runs the weekly activity report for the previous week ending"
      task :renewals => :environment do
        ContractRenewer.execute
      end

      task :build_historical => :environment do
        FinancialKpiBuilder.build_weekly_historicals
        FinancialKpiBuilder.build_monthly_historicals
      end
    end
  end
end
