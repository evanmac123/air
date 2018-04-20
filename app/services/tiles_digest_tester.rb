# frozen_string_literal: true

class TilesDigestTester
  include TilesDigestConcern

  attr_reader :digest, :current_user, :follow_up_day, :subject, :alt_subject

  def initialize(digest_form:, population_segment_id: nil)
    digest_params = test_digest_params(digest_form, population_segment_id)

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
          "TilesDigestPresenter"
        ).deliver_now
      end
    end

    def deliver_test_follow_up_email
      unless follow_up_day == "Never"
        TilesDigestMailer.notify_one(
          digest,
          current_user.id,
          test_follow_up_subject,
          "FollowUpDigestPresenter"
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

    def test_digest_params(digest_form, segment_id)
      demo = digest_form.demo
      tile_ids = demo.digest_tiles.segmented_on_population_segments([segment_id.to_i])

      {
        id: "test",
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
