desc "This task is called by the Heroku cron add-on"
task :deliver_follow_up_digest_email => :environment do
  FollowUpDigestBulkMailJob.perform_now
end
