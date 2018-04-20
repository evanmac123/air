# frozen_string_literal: true

class TilesDigestPresenter
  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  DIGEST_EMAIL = "tile_digest"
  FOLLOWUP_EMAIL = "follow_up_digest"
  STANDARD_DIGEST_HEADING = "Your New Tiles Are Here!"
  STANDARD_FOLLOWUP_HEADING = "Don't miss your new tiles"

  attr_reader :demo, :user, :digest, :subject, :custom_message

  def initialize(digest, user, subject)
    @digest = digest
    @user = user
    @demo = digest.demo
    @subject = subject
    @custom_message = digest.message
  end

  def follow_up_email
    false
  end

  def slice_size
    3
  end

  def link_options
    {}
  end

  def works_on_mobile?
    false
  end

  def from_email
    demo.reply_email_address
  end

  def email_heading
    if headline.present?
      headline
    else
      standard_email_heading
    end
  end

  def headline
    digest.headline
  end

  def standard_email_heading
    STANDARD_DIGEST_HEADING
  end

  def email_type
    DIGEST_EMAIL
  end

  def general_site_url(tile_id: nil, options: {})
    link_options = {
      email_type: email_type,
      tiles_digest_id: digest.id,
      tile_id: tile_id,
      subject_line: subject_line_param
    }.merge(options)

    digest_email_site_link(user, demo.id, link_options)
  end

  def subject_line_param
    URI.encode(subject.to_s, /\W/)
  end

  def body_for_text_message(tile_id)
    "#{general_site_url(tile_id: tile_id, options: { from_sms: true })} #{subject}"
  end
end
