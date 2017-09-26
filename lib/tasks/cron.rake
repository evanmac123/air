desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  TilesDigestMailer.notify_all_follow_up
end
