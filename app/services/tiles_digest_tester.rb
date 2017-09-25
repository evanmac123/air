class TilesDigestTester
  include TilesDigestConcern

  attr_reader :digest, :current_user, :follow_up_day

  def initialize(digest_form:)
    digest_params = test_digest_params(digest_form)

    @digest = OpenStruct.new(digest_params)
    @current_user = digest_form.current_user
    @follow_up_day = digest_form.follow_up_day
  end

  def deliver_test!
    subject = sanitize_subject_line(digest.subject)
    alt_subject = sanitize_subject_line(digest.alt_subject)

    [subject, alt_subject].compact.each do |s|
      TilesDigestMailer.delay.notify_one(
        digest,
        current_user.id,
        "[Test] #{s}",
        TilesDigestMailDigestPresenter
      )
    end

    unless follow_up_day == 'Never'
      [subject, alt_subject].compact.each do |s|
        TilesDigestMailer.delay.notify_one(
          digest,
          current_user.id,
          "[Test] Don't Miss: #{s}",
          TilesDigestMailFollowUpPresenter
        )
      end
    end
  end


  private

    def test_digest_params(digest_form)
      cutoff_time = digest_form.demo.tile_digest_email_sent_at
      tile_ids = digest_form.demo.digest_tiles(cutoff_time).pluck(:id)

      {
        id: "test",
        cutoff_time: cutoff_time,
        tile_ids_for_email: tile_ids,
        demo: digest_form.demo,
        subject: digest_form.custom_subject || TilesDigest::DEFAULT_DIGEST_SUBJECT,
        alt_subject: digest_form.alt_custom_subject,
        headline: digest_form.custom_headline,
        message: digest_form.custom_message,
      }
    end
end
