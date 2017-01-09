namespace :admin do
  namespace :reports do
    namespace :customer_success do
      desc "Runs the weekly customer_success"

      task :build_daily => [:environment] do
        Reporting::CustomerSuccessKpiBuilder.build_current_week
        Reporting::CustomerSuccessKpiBuilder.build_current_month
      end


      task :build_historical => :environment do
        Reporting::CustomerSuccessKpiBuilder.build_weekly_historicals
        Reporting::CustomerSuccessKpiBuilder.build_monthly_historicals
      end

    end
  end
end
