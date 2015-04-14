class DigestMuteSliderPresenter < BaseEmailMuteSliderPresenter
  def email_type
    'digest'
  end

  def disabled?
    false
  end

  def mute_url
    mute_digest_path(board_id)
  end
end
