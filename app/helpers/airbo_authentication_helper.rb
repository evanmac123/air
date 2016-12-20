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
    return if authenticate_user
    return if authenticate_by_tile_token
    return if authenticate_by_onboarding_auth_hash
    return if authenticate_as_potential_user
    return if authenticate_by_explore_token
    return if authenticate_as_guest_user
  end

  def authenticated?
    if current_user
      refresh_activity_session(current_user)
      return true
    else
      return false
    end
  end

  def authenticate_user
    return false unless params[:password]
    clearance_authenticate
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
      return true
    else
      return false
    end
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

    # FIXME the code here is doing too much. this method should simply return
    # true/false and should be moved to a Pundit policy on these three specific actions.
    #----------------------------------------------------------
    allowed_pathes = [activity_path, potential_user_conversions_path, ping_path]
    if @potential_user && !allowed_pathes.include?(request.path)
      redirect_to activity_path
    elsif @potential_user
      return true
    else
      return false
    end
  end

  def authenticate_by_explore_token
    return false unless explore_token_allowed

    explore_token = find_explore_token
    return false unless explore_token.present?

    user = User.find_by_explore_token(explore_token)
    return false unless user.present? && user.is_client_admin_in_any_board

    remember_explore_token(explore_token)

    refresh_activity_session(user)
    remember_explore_user(UserRestrictedToExplorePages.new(user))
    return true
  end

  def authenticate_as_guest_user
    return false unless guest_user_allowed? && (logged_in_as_guest? || !current_user)

    login_as_guest(find_current_board)
    return true
  end

  def should_authenticate_by_tile_token?(tile_token, user)
    user && user.end_user? && EmailLink.validate_token(user, tile_token)
  end

  def login_as_guest(demo = nil)
    unless current_user
      demo = demo || Demo.new
      session[:guest_user] = { demo_id: demo.id }

      if session[:guest_user_id]
        session[:guest_user][:id] = session[:guest_user_id]
      end

      @guest_user = find_or_create_guest_user
      refresh_activity_session(current_user)
    end
  end

  def logged_in_as_guest?
    session[:guest_user].present? && current_user.is_a?(GuestUser)
  end

  def set_show_conversion_form_before_this_request
    session[:conversion_form_shown_before_this_request] = session[:conversion_form_shown_already]
  end

  def show_conversion_form_provided_that(allow_reshow = false)
    # TODO: This conversion form nonsense is totally fucked. Why on earth is this coupled to authentication and app controller????
    # uncommenting this next line is handy for e.g. working on style or copy of
    # conversion form, as it will make the conversion form always pop.
    #return(@show_conversion_form = true)

    return if session[:conversion_form_shown_already] && !(allow_reshow)
    return unless current_user && current_user.is_guest?
    demo = current_user.try(:demo)
    return if demo && $rollout.active?(:suppress_conversion_modal, demo)

    @show_conversion_form = yield
    session[:conversion_form_shown_already] = @show_conversion_form
  end

  def remember_explore_user(user)
    @current_user_by_explore_token = user
  end

  def remember_explore_token(explore_token)
    session[:explore_token] = explore_token
  end

  def find_explore_token
    params[:explore_token] || session[:explore_token]
  end

  def explore_token_allowed
    false
  end

  # TODO: Move to policies!
  def allow_guest_user
    @guest_user_allowed_in_action = true
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

  def persist_guest_user
    if current_user.try(:is_guest?)
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

  def override_public_board_setting
    false
  end
end
