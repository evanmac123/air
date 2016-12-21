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
    return if authenticated?
    return if authenticate_by_tile_token
    return if authenticate_by_onboarding_auth_hash
    return if authenticate_as_potential_user
    login_as_guest(find_current_board) if guest_user_allowed?
    authenticate_user
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

  def authenticate_by_tile_token
    return false unless params[:tile_token]
    user = User.find_by_id(params[:user_id])
    email_clicked_ping(user)

    if should_authenticate_by_tile_token?(params[:tile_token], user)
      sign_in(user, 1)
      user.move_to_new_demo(params[:demo_id]) if params[:demo_id].present?
      flash[:success] = "Welcome back, #{user.first_name}"
    else
      authenticate_user
    end
  end

  def should_authenticate_by_tile_token?(tile_token, user)
    user && user.end_user? && EmailLink.validate_token(user, tile_token)
  end

  def authenticate_by_onboarding_auth_hash
    return false unless cookies[:user_onboarding].present?
    user_onboarding = UserOnboarding.find_by_auth_hash(auth_hash: cookies[:user_onboarding])
    if user_onboarding && !user_onboarding.completed
      sign_in(user_onboarding.user)
      refresh_activity_session(current_user)
      return true
    else
      return false
    end
  end

  def authenticate_as_potential_user
    return false unless session[:potential_user_id].present?
    @potential_user = PotentialUser.find_by_id(session[:potential_user_id])

    allowed_pathes = [activity_path, potential_user_conversions_path]
    if @potential_user && !allowed_pathes.include?(request.path)
      redirect_to activity_path
    elsif @potential_user
      return true
    else
      return false
    end
  end

  def login_as_guest(demo)
    unless current_user
      session[:guest_user] = { demo_id: demo.try(:id) }
      if session[:guest_user_id]
        session[:guest_user][:id] = session[:guest_user_id]
      end
      @guest_user = find_or_create_guest_user
      session[:guest_user] = current_user.to_guest_user_hash
    end
  end

  def logged_in_as_guest?
    session[:guest_user].present? && current_user.is_a?(GuestUser)
  end

  def remember_explore_user(user)
    @current_user_by_explore_token = user
  end

  # TODO: Move to policies!
  def allow_guest_user
    @guest_user_allowed_in_action = true
  end

  def allow_guest_user_if_public
    if params[:public_slug]
      allow_guest_user
    end
  end

  def guest_user_allowed?
    @guest_user_allowed_in_action
  end

  def find_current_board
    nil
  end

  def current_user_by_explore_token
    nil
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

  def override_public_board_setting
    false
  end
end
