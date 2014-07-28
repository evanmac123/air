class MuteFollowupsController < MuteController
  protected

  def attribute_to_mute
    :followup_muted
  end
end
