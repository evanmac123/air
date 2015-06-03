namespace :reports do
	namespace :client_admin do
		desc "Runs the weekly activity report for the previous week ending"
		task :weekly_activity => :environment do
			collector = ActiveBoardCollector.new
			collector.send_mail_notifications
		end
	end
end
