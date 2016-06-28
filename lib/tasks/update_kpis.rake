namespace :reports do
  namespace :interal do
    desc "Runs the weekly KPI updater previous week ending"
    task :weekly_activity => :environment do
      if Date.today.wday ==1
        collector = ActiveBoardCollector.new
        collector.send_mail_notifications
      else
        Rails.logger.warn "Skipping Activity Report Not Monday"
      end
    end
  end
end
