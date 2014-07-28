class MuteDigestsController < MuteController
  protected

  def attribute_to_mute
    :digest_muted
  end
end
