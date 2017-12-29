desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  FollowUpDigestBulkMailJob.perform_now
end
