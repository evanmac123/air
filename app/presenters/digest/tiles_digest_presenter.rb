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
    "#{demo.name}: #{subject} #{general_site_url(tile_id: tile_id, options: { from_sms: true })}"
  end

  def ribbon_tag_font_color(color)
    hex = if color.length == 7
      color[1..-1]
    else
      color[1] + color[1] + color[2] + color[2] + color[3] + color[3]
    end
    red = Integer(hex[0..1], 16)
    green = Integer(hex[2..3], 16)
    blue = Integer(hex[4..5], 16)
    (red * 0.299 + green * 0.587 + blue * 0.114) > 186 ? "#000000" : "#FFFFFF"
  end
end
