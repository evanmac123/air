module AirboAuthorizationHelper
  ACTIVITY_SESSION_THRESHOLD = ENV['ACTIVITY_SESSION_THRESHOLD'].try(:to_i) || 900 # in seconds

  def current_user
    super
  end

  def authorize_with_onboarding_auth_hash
    if cookies[:user_onboarding].present? && current_user.nil?
      user_onboarding = UserOnboarding.where(auth_hash: cookies[:user_onboarding]).first
      if user_onboarding && !user_onboarding.completed
        sign_in(user_onboarding.user)
        refresh_activity_session(current_user)
      end
    end
  end


  def authenticate_as_potential_user
    if session[:potential_user_id].present? && !current_user
      @_potential_user = PotentialUser.find(session[:potential_user_id])
      # FIXME the code here is doing too much. this method should simply return
      # true/false
      #----------------------------------------------------------
      allowed_pathes = [activity_path, potential_user_conversions_path, ping_path]
      if @_potential_user && !allowed_pathes.include?(request.path)
        redirect_to activity_path
      end
      #------------------------------------------------------------
      #FIXME
      @_potential_user.present?
    end
  end

  def authenticate_as_guest
    if logged_in_as_guest?
      if guest_user_allowed?
        board = find_current_board # must be implemented in subclass
        unless override_public_board_setting || (board && board.is_public)
          public_board_not_found
        end

        refresh_activity_session(current_user)
        return true
      else
        # TODO: DEPRECATE test_suite_remediation: I think these flash messages are deprecated in the user flow.  Should remove along with pending specs in spec/acceptance/guest_user/gets_helpful_message_if_they_try_to_break_out_of_the_sandbox_spec.rb
        guest = GuestUser.where(id: session[:guest_user_id]).first
        demo = guest.try(:demo)
        if demo && $rollout.active?(:suppress_conversion_modal, demo)
        #FIXME this rollout is deprecated so this branch is no longer reachable
          flash[:failure] = "Sorry, you don't have permission to access that part of the site."
        else
          flash[:failure] = '<a href="#" class="open_save_progress_form">Save your progress</a> to access this part of the site.'
          flash[:failure_allow_raw] = true
        end
        #
        #FIXME WTF why are finding guest user twice????
        redirect_to public_activity_path(claimed_guest_user.demo.public_slug)
        return true
      end
    end
  end

  def login_as_guest(demo)
    session[:guest_user] = {demo_id: demo.id}
    if session[:guest_user_id]
      session[:guest_user][:id] = session[:guest_user_id]
    end
    refresh_activity_session(current_user)
  end

  def authenticate_to_public_board
    return false unless guest_user_allowed? && params[:public_slug]

    demo = Demo.public_board_by_public_slug(params[:public_slug])
    unless demo
      public_board_not_found
      return true
    end

    if current_user.nil?
      login_as_guest(demo)
    else
      if current_user.demos.include? demo
        current_user.move_to_new_demo demo
      else
        current_user.add_board demo
        current_user.move_to_new_demo demo
        current_user.get_started_lightbox_displayed = false
        current_user.session_count = 1
        current_user.save
        flash[:success] = "You've now joined the #{demo.name} board!"
      end
      redirect_to activity_path
    end

    true
  end

  def authenticate_by_explore_token
    return if current_user
    return unless explore_token_allowed

    explore_token = find_explore_token
    return unless explore_token.present?

    user = User.find_by_explore_token(explore_token)
    return unless user.present? && user.is_client_admin_in_any_board

    remember_explore_token(explore_token)

    refresh_activity_session(user)
    remember_explore_user(UserRestrictedToExplorePages.new(user))
  end

  def set_show_conversion_form_before_this_request
    session[:conversion_form_shown_before_this_request] = session[:conversion_form_shown_already]
  end

  def show_conversion_form_provided_that(allow_reshow = false)
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

  def refresh_activity_session(user)
    return if user.nil? || user.is_a?(PotentialUser)

    if user.is_a? User
      session[:user_id] = user.id
    elsif user.is_a? GuestUser
      session[:guest_user_id] = user.id
    end

    # We rig the timestamp to ensure that these always appear to Mixpanel to happen after the corresponding email ping (as in email_clicked_ping) if any.
    if idle_period >= ACTIVITY_SESSION_THRESHOLD
      time = request.env['rack.timestamp'] || Time.now
      ping('Activity Session - New', {time: time - 1}, user)
    end

    set_last_session_activity
  end

  def explore_token_allowed
    false
  end

  def claimed_guest_user
    GuestUser.find(session[:guest_user][:id])
  end

  def public_board_not_found
    render 'shared/public_board_not_found', layout: 'external_marketing'
  end

  def current_user_with_guest_user
    return @_potential_user if @_potential_user && !current_user_without_guest_user
    return current_user_without_guest_user unless guest_user_allowed?

    if (user = current_user_without_guest_user)
      return user
    end

    if logged_in_as_guest?
      @_guest_user ||= find_or_create_guest_user
      @_guest_user
    else
      nil
    end
  end
  alias_method_chain :current_user, :guest_user

  def force_html_format
    request.format = :html
  end

  def allow_guest_user
    @guest_user_allowed_in_action = true
  end

  def guest_user_allowed?
    @guest_user_allowed_in_action
  end

  def logged_in_as_guest?
    session[:guest_user].present? && current_user_without_guest_user.nil? && current_user_by_explore_token.nil?
  end

  # Note that subclasses of ApplicationController must implement their own
  # board_is_public? method if they want to use allow_guest_user, since
  # there's no single way that we decide which board is pertinent in which
  # action.

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
      guest_user = GuestUser.find(session[:guest_user][:id])
      if params[:public_slug]
        board = Demo.find_by_public_slug(params[:public_slug])
        if board.present? && guest_user.demo_id != board.id
          guest_user.demo = board
          guest_user.save!
        end
      end
      guest_user
    else
      GuestUser.create!(session[:guest_user])
    end
  end

  def not_found
    render file: "#{Rails.root}/public/404", status: :not_found, layout: false, formats: [:html]
  end

  def decide_if_tiles_can_be_done(satisfiable_tiles)
    @all_tiles_done = satisfiable_tiles.empty?
    @no_tiles_to_do = current_user.demo.tiles.active.empty?
  end

  def disable_mime_sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
  end

  def allow_same_origin_framing
    @allow_same_origin_framing = true
  end

  def disable_framing
    response.headers['X-Frame-Options'] = frame_option
  end

  def frame_option
    @allow_same_origin_framing ? 'SAMEORIGIN' : 'DENY'
  end

  def override_public_board_setting
    false
  end

  def no_newrelic_for_site_admins
    # The second conditional is a stupid hack because of the mess our
    # authentication system is. Site admins have hundreds of boards available,
    # other users don't.
    if (current_user && current_user.is_site_admin) || (@boards_to_switch_to && @boards_to_switch_to.length > 100)
      ignore_all_newrelic
    end
  end

  def ignore_all_newrelic
    NewRelic::Agent.ignore_transaction
  end

  def set_last_session_activity
    session[:last_activity] = Time.now
  end

  def last_session_activity
    session[:last_activity].to_i || 0
  end

  def idle_period
    @difference ||= Time.now.to_i - last_session_activity
  end

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end

  def force_ssl
    return true unless prod_or_testing_ssl_outside_of_prod
    redirect_required = false
    unless request.subdomain.present?
      redirect_required = true
    end
    unless request.ssl?
      redirect_required = true
    end

    if redirect_required
      redirect_hostname = hostname_with_subdomain
      redirection_parameters = {
        :protocol   => 'https',
        :host       => redirect_hostname,
        :action     => action_name,
        :controller => controller_name
      }.reverse_merge(params)

      redirect_to redirection_parameters
      return false
    end
  end

  def prod_or_testing_ssl_outside_of_prod
    Rails.env.production? || $test_force_ssl
  end

  #Deprecated? =>
  def current_user_is_site_admin
    current_user && current_user.is_site_admin
  end

  def going_to_settings
    controller_name == "settings"
  end

  def game_not_yet_begun?
    current_user && current_user.demo.game_not_yet_begun?
  end

  def hostname_without_subdomain
    request.subdomain.present? ? request.host.gsub(/^[^.]+\./, '') : request.host
  end
end
