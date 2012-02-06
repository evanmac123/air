desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Demo.recalculate_all_moving_averages!
  User.reset_all_mt_texts_today_counts!
end
