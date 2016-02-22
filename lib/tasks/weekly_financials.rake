namespace :admin do
  namespace :reports do
    namespace :financials do
      desc "Runs the weekly Financials report for the previous week"
      task :populate_weekly => :environment do
        today = Date.today
        if today.wday ==0 || ENV["FORCE_FIN_CALC"]="on"
          sdate = today.beginning_of_week
          edate = today
          FinancialsReporterService.execute sdate, edate
        else
          Rails.logger.warn "Not Sunday Skipping Financials Report"
        end
      end


      task :populate_historical => :environment do
        FinancialsReporterService.populate_historical
      end
    end
  end
end
