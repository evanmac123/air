class TilesDigestMailPreviewFollowupPresenter < TilesDigestMailPreviewDigestPresenter
  def slice_size
    1
  end

  def follow_up_email
    true
  end

  def email_heading
    join_demo_copy_or_digest_email_heading(is_invite_user)
  end

  def digest_email_heading
    STANDARD_FOLLOWUP_HEADING
  end

  def email_type
    FOLLOWUP_EMAIL
  end
end
