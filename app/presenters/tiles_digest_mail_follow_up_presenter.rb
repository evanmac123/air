class TilesDigestMailerFollowupPresenter < TilesDigestMailDigestPresenter
  def slice_size
    1
  end

  def follow_up_email
    true
  end

  def standard_email_heading
    STANDARD_FOLLOWUP_HEADING
  end

  def email_type
    FOLLOWUP_EMAIL
  end
end
