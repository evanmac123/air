desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  User.reset_all_mt_texts_today_counts!
  TilesDigestMailer.notify_all_from_delayed_job
end
