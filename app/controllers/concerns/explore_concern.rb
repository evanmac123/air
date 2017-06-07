module ExploreConcern

  def explore_email_clicked_ping(user:, email_type:, email_version:)
    properties = {
      email_type: email_type,
      email_version: email_version,
    }

    ping("Email clicked", properties, user)
  end

  def track_user_channels(list)
    if current_user.is_a?(User)
      current_user.delay.track_channels(list)
    end
  end
end
