class TilesDigestMailDigestPresenter < TilesDigestMailBasePresenter
  DIGEST_EMAIL = "digest_new_v".freeze
  FOLLOWUP_EMAIL = "follow_new_v".freeze

  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  def initialize(user, demo, custom_from, custom_message, follow_up_email, is_new_invite)
    super(custom_message)
    @user = user
    @demo = demo
    @custom_from = custom_from
    @follow_up_email = follow_up_email
    @is_new_invite = is_new_invite
  end

  def follow_up_email
    @follow_up_email
  end

  def slice_size
    follow_up_email ? 1 : 3
  end

  def from_email
    if @custom_from.present?
      @custom_from
    else
      @demo.reply_email_address
    end
  end

  def email_heading
    if follow_up_email
      STANDARD_FOLLOWUP_HEADING
    else
      STANDARD_DIGEST_HEADING
    end
  end

  def title
    join_demo_copy_or_digest_email_heading(@is_new_invite)
  end

  def email_type
    if follow_up_email
      FOLLOWUP_EMAIL
    else
      DIGEST_EMAIL
    end
  end

  def general_site_url
    email_site_link(@user, @demo, is_preview, email_type)
  end
end
