module ExploreConcern
  def track_user_channels(list)
    if current_user.is_a?(User)
      current_user.delay.track_channels(list)
    end
  end
end
