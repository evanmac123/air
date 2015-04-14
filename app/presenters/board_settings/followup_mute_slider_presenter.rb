class FollowupMuteSliderPresenter < BaseEmailMuteSliderPresenter
  def email_type
    'followup'
  end

  def disabled?
    digest_is_muted
  end

  def mute_url
    mute_followup_path(board_id)
  end
end
