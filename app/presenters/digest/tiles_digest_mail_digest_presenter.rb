class TilesDigestMailDigestPresenter < TilesDigestMailBasePresenter
  DIGEST_EMAIL = "tile_digest".freeze
  FOLLOWUP_EMAIL = "follow_up_digest".freeze

  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  def initialize(digest, user, subject, is_invite_user)
    super(digest.message)
    @digest = digest
    @user = user
    @demo = digest.demo
    @subject = subject
    @is_invite_user = is_invite_user
  end

  def follow_up_email
    false
  end

  def slice_size
    3
  end

  def from_email
    @demo.reply_email_address
  end

  def link_options
    opts = { tiles_digest_id: @digest.id }
    opts.merge({ subject: @subject }) if @subject
    opts
  end

  def email_heading
    @digest.headline.present? ? @digest.headline : standard_email_heading
  end

  def standard_email_heading
    STANDARD_DIGEST_HEADING
  end

  def email_type
    DIGEST_EMAIL
  end

  def general_site_url
    "#{email_site_link(@user, @demo, is_preview, email_type)}&tiles_digest_id=#{@digest.id}"
  end

  def title
    join_demo_copy_or_digest_email_heading(@is_invite_user)
  end
end
