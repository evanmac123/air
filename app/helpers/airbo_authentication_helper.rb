module AirboAuthenticationHelper
  def current_user
    super || potential_user || guest_user
  end

  def potential_user
    @potential_user
  end

  def guest_user
    @guest_user
  end

  def authenticate
    return true
  end

  def authenticated?
    if current_user || signed_in?
      refresh_activity_session(current_user)
      return true
    else
      return false
    end
  end

  def authenticate_user
    clearance_authenticate unless current_user
    refresh_activity_session(current_user)
  end

  def find_current_board
    nil
  end

  def login_as_guest(demo = find_current_board)
    unless current_user
      session[:guest_user] = { demo_id: demo.try(:id) }
      if session[:guest_user_id]
        session[:guest_user][:id] = session[:guest_user_id]
      end
      @guest_user = find_or_create_guest_user
      session[:guest_user] = current_user.to_guest_user_hash
    end
  end

  def find_or_create_guest_user
    if session[:guest_user][:id].present?
      guest = GuestUser.find(session[:guest_user][:id])
      if params[:public_slug]
        board = Demo.find_by_public_slug(params[:public_slug])
        if board.present? && guest.demo_id != board.id
          guest.demo = board
          guest.save!
        end
      end
      guest
    else
      GuestUser.create!(session[:guest_user])
    end
  end
end
