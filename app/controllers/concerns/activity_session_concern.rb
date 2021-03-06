# frozen_string_literal: true

module ActivitySessionConcern
  ACTIVITY_SESSION_THRESHOLD = 15.minutes

  def refresh_activity_session
    return unless current_user && !current_user.is_a?(PotentialUser)
    update_session_with_user_id(current_user)
    time = request.env["rack.timestamp"] || Time.current.to_i

    if idle_period(time) >= ACTIVITY_SESSION_THRESHOLD
      send_activity_session_ping(time)
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
    session[:points] = current_board && current_board.organization.try(:id) == 1072 ? "complete" : "points"
    if user.is_a?(User)
      session[:user_id] = user.id
    elsif user.is_a?(GuestUser)
      session[:guest_user_id] = user.id
    end
  end

  private

    def send_activity_session_ping(time)
      unless current_user.is_site_admin
        ping("Activity Session - New", { time: time }, current_user)
      end
    end
end
