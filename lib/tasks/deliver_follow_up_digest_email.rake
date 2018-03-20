desc "queues up jobs to deliver follow up digests at noon est"
task :deliver_follow_up_digest_email => :environment do
  FollowUpDigestBulkMailJob.perform_now
end
