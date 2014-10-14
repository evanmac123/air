class TilesDigestMailDigestPresenter < TilesDigestMailBasePresenter
  DIGEST_EMAIL = "digest_new_v".freeze
  FOLLOWUP_EMAIL = "follow_new_v".freeze

  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  def initialize(user, demo, custom_from, custom_headline, custom_message, is_new_invite)
    super(custom_message)
    @user = user
    @demo = demo
    @custom_from = custom_from
    @is_new_invite = is_new_invite
    @custom_headline = custom_headline
  end

  def follow_up_email
    false
  end

  def slice_size
    3
  end

  def from_email
    if @custom_from.present?
      @custom_from
    else
      @demo.reply_email_address
    end
  end

  def email_heading
    @custom_headline.present? ? @custom_headline : standard_email_heading
  end

  def standard_email_heading
    STANDARD_DIGEST_HEADING
  end

  def title
    join_demo_copy_or_digest_email_heading(@is_new_invite)
  end

  def email_type
    DIGEST_EMAIL
  end

  def general_site_url
    email_site_link(@user, @demo, is_preview, email_type)
  end

  def invitation_link
    @user.claimed? ? nil : general_site_url
  end
end
