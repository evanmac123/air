class TilesDigestBulkMailJob < ActiveJob::Base
  queue_as :bulk_mail

  def perform(digest)
    digest.user_ids_to_deliver_to.each_with_index do |user_id, idx|
      subject = digest.resolve_subject(idx)
      TilesDigestMailer.notify_one(digest, user_id, subject, "TilesDigestMailDigestPresenter").deliver_later
    end
  end
end
