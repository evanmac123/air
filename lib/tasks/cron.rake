desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Demo.recalculate_all_moving_averages!
end
