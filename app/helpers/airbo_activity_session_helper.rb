module AirboActivitySessionHelper
  ACTIVITY_SESSION_THRESHOLD = 15.minutes

  def refresh_activity_session(user)
    return if user.nil? || user.is_a?(PotentialUser)
    update_session_with_user_id(user)
    time = request.env['rack.timestamp'] || Time.now.to_i

    if idle_period(time) >= ACTIVITY_SESSION_THRESHOLD
      ping('Activity Session - New', { time: time }, user)
    end

    set_last_session_activity(time)
  end

  def set_last_session_activity(time)
    session[:last_activity] = time
  end

  def idle_period(time)
    time - last_session_activity
  end

  def last_session_activity
    session[:last_activity].to_i || 0
  end

  def  update_session_with_user_id(user)
    if user.is_a? User
      session[:user_id] = user.id
    elsif user.is_a? GuestUser
      session[:guest_user_id] = user.id
    end
  end
end
