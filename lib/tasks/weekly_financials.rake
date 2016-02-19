namespace :reports do
  namespace :admin do
    desc "Runs the weekly Financials report for the previous week"
    task :weekly_financials => :environment do
      today = Date.today
      if today.wday ==0 || ENV["FORCE_FIN_CALC"]="on"
        sdate = today.beginning_of_week
        edate = today
        FinancialsReporterService.execute sdate, edate
      else
        Rails.logger.warn "Not Sunday Skipping Financials Report"
      end
    end


    task :past_financials => :environment do
      if Contract.count==0 || Organization.count == 0
        Rails.logger.warn "Skipping Activity Report Not Monday"
      else
        min_start = Contract.minimum(:start_date)
        sdate = min_start.beginning_of_week
        edate = min_start.end_of_week
        while sdate < Date.today do 
          FinancialsReporterService.execute sdate, edate
          sdate = sdate.next_week
        end
      end
    end
  end
end
