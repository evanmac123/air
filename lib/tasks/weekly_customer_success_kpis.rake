namespace :admin do
  namespace :reports do
    namespace :customer_success do
      desc "Runs the weekly customer_success"

      task :build_daily => [:environment] do
        weekly_report = Reporting::CustomerSuccessKpiBuilder.build_current_week
        CustomerSuccessKpisMailer.daily_update(weekly_report)

        monthly_report = Reporting::CustomerSuccessKpiBuilder.build_current_month
        CustomerSuccessKpisMailer.daily_update(monthly_report)
      end

      task :build_historical => :environment do
        Reporting::CustomerSuccessKpiBuilder.build_weekly_historicals
        Reporting::CustomerSuccessKpiBuilder.build_monthly_historicals
      end
    end
  end
end
