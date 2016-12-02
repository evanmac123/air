namespace :admin do
  namespace :reports do
    desc "Runs the weekly customer_success"
    task :customer_success_weekly => :environment do
      today = Date.today
      if today.wday==1
        r = Reporting::CustomerSuccessKpiBuilder.new
        r.build
      else
        Rails.logger.warn "Not monday Skipping KPI Report"
      end
    end
  end
end
