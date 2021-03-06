namespace :reports do
  namespace :client_admin do
    desc "Runs the weekly activity report for the previous week ending"
    task :weekly_activity => :environment do
      if Date.current.wday ==1
        collector = ActiveBoardCollector.new
        collector.send_mail_notifications
      else
        Rails.logger.warn "Skipping Activity Report Not Monday"
      end
    end
  end
end
