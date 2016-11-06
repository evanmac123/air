namespace :admin do
  namespace :reports do
    namespace :financials do
      desc "Runs the weekly Financials report for the previous week"
      task :populate_weekly => :environment do
        today = Date.today
        if today.wday==1
          FinancialsReporterService.build_week today
        else
          Rails.logger.warn "Not monday Skipping Financials Report"
        end
      end


      task :build_historical => :environment do
        FinancialsReporterService.build_historical
      end
    end
  end
end
