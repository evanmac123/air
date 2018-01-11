class ExploreDigestBulkMailJob < ActiveJob::Base
  queue_as :bulk_mail

  def perform(explore_digest, users = nil)
    users ||= User.client_admin.where(receives_explore_email: true)
    users.each { |user|
      ExploreDigestMailer.notify_one(explore_digest, user).deliver_later
    }
  end
end
