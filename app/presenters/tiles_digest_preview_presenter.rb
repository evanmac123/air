class TilesDigestMailPreviewPresenter < TilesDigestMailBasePresenter
  def initialize(custom_message, demo, is_invite_user)
    super(custom_message)
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

  attr_reader :is_invite_user
end
