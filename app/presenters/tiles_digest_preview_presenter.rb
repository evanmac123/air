class TilesDigestMailPreviewPresenter < TilesDigestMailBasePresenter
  include ClientAdmin::TilesHelper
  include Rails.application.routes.url_helpers

  def initialize(user, demo, custom_message, is_invite_user)
    super(custom_message)
    @user = user
    @demo = demo
    @is_invite_user = is_invite_user
  end

  def link_options
    {target: '_blank'}  
  end

  def is_preview
    true
  end

  def title
    join_demo_copy_or_digest_email_heading(is_invite_user)
  end

  def email_heading
    join_demo_copy_or_digest_email_heading(is_invite_user)
  end

  def general_site_url
    "User's Unique Access Link Goes Here"
  end

  attr_reader :is_invite_user
end
