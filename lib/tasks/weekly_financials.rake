namespace :admin do
  namespace :reports do
    namespace :financials do
      desc "Runs the weekly Financials report for the previous week"
      task :populate_weekly => :environment do
        today = Date.today
        if today.wday==1
          FinancialKpiBuilder.build_weekly_historicals(Date.yesterday)
        else
          Rails.logger.warn "Not monday Skipping Financials Report"
        end
      end

      task :populate_daily => :environment do
          FinancialKpiBuilder.build_current_week
          FinancialKpiBuilder.build_current_month
      end

      task :build_historical => :environment do
        FinancialKpiBuilder.build_weekly_historicals
        FinancialKpiBuilder.build_monthly_historicals
      end
    end
  end
end
