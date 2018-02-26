# frozen_string_literal: true

class TilesDigestPresenter
  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  DIGEST_EMAIL = "tile_digest".freeze
  FOLLOWUP_EMAIL = "follow_up_digest".freeze
  STANDARD_DIGEST_HEADING = "Your New Tiles Are Here!".freeze
  STANDARD_FOLLOWUP_HEADING = "Don't miss your new tiles".freeze

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

  def custom_message_if_present
    custom_message.present? ? custom_message : ""
  end

  def from_email
    demo.reply_email_address
  end

  def email_heading
    if digest.headline.present?
      digest.headline
    else
      standard_email_heading
    end
  end

  def standard_email_heading
    STANDARD_DIGEST_HEADING
  end

  def email_type
    DIGEST_EMAIL
  end

  def general_site_url(tile_id: nil)
    "#{digest_email_site_link(user, demo.id, email_type)}&tiles_digest_id=#{digest.id}#{subject_line_param.to_s}#{tile_id_param(tile_id)}"
  end

  def subject_line_param
    uri_encoded_subject = URI.encode(subject.to_s, /\W/)
    if uri_encoded_subject.present?
      "&subject_line=#{uri_encoded_subject}"
    end
  end

  def tile_id_param(tile_id)
    if tile_id.present?
      "&tile_id=#{tile_id}"
    end
  end

  def body_for_text_message
    "#{general_site_url(tile_id: digest.tile_ids.first)}&from_sms=true #{subject}"
  end
end
