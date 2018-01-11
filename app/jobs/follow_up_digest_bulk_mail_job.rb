class FollowUpDigestBulkMailJob < ActiveJob::Base
  queue_as :bulk_mail

  def perform
    FollowUpDigestEmail.send_follow_up_digest_email.each do |followup|
      followup.delay(run_at: noon_est).trigger_deliveries
    end
  end

  private

    def noon_est
      Time.current.in_time_zone("Eastern Time (US & Canada)").midnight.advance(hours: 12)
    end
end
