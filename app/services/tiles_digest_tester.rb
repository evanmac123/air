# frozen_string_literal: true

class TilesDigestTester
  include TilesDigestConcern

  attr_reader :digest, :current_user, :follow_up_day, :subject, :alt_subject

  def initialize(digest_form:)
    digest_params = test_digest_params(digest_form)

    @digest = OpenStruct.new(digest_params)
    @current_user = digest_form.current_user
    @follow_up_day = digest_form.follow_up_day
    @subject = sanitize_subject_line(digest.subject)
    @alt_subject = sanitize_subject_line(digest.alt_subject)
  end

  def deliver_test
    deliver_test_tile_email
    deliver_test_follow_up_email
  end

  private

    def deliver_test_tile_email
      [subject, alt_subject].compact.each do |subject|
        TilesDigestMailer.notify_one(
          digest,
          current_user.id,
          "[Test] #{subject}",
          "TilesDigestMailDigestPresenter"
        ).deliver_now
      end
    end

    def deliver_test_follow_up_email
      unless follow_up_day == "Never"
        TilesDigestMailer.notify_one(
          digest,
          current_user.id,
          test_follow_up_subject,
          "TilesDigestMailFollowUpPresenter"
        ).deliver_now
      end
    end

    def test_follow_up_subject
      if alt_subject.present?
        "[Test] Don't Miss: #{subject} / Don't Miss: #{alt_subject}"
      else
        "[Test] Don't Miss: #{subject}"
      end
    end

    def test_digest_params(digest_form)
      demo = digest_form.demo
      cutoff_time = demo.tile_digest_email_sent_at
      tile_ids = demo.digest_tiles.pluck(:id)

      {
        id: "test",
        cutoff_time: cutoff_time,
        tile_ids: tile_ids,
        demo: demo,
        subject: digest_form.custom_subject || TilesDigest::DEFAULT_DIGEST_SUBJECT,
        alt_subject: digest_form.alt_custom_subject,
        headline: digest_form.custom_headline,
        message: digest_form.custom_message,
        include_sms: digest_form.include_sms
      }
    end
end
