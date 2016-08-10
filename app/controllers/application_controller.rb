class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)
  ACTIVITY_SESSION_THRESHOLD = ENV['ACTIVITY_SESSION_THRESHOLD'].try(:to_i) || 900 # in seconds

  EMAIL_PING_TEXT_TYPES = {
    "digest_old_v" => "Digest  - v. Pre 6/13/14",
    "digest_new_v" => "Digest - v. 6/15/14",
    "follow_old_v" => "Follow-up - v. pre 6/13/14",
    "follow_new_v" => "Follow-up - v. 6/15/14",
    "explore_v_1"  => "Explore - v. 8/25/14"
  }

  before_filter :force_ssl
  before_filter :authorize
  before_filter :disable_mime_sniffing
  before_filter :disable_framing
  before_filter :initialize_flashes
  before_filter :set_show_conversion_form_before_this_request
	before_filter :enable_miniprofiler #NOTE on by default in development
  # TODO: DEPRECATE remove after removing yell_name method
  # This prints the controller and action to stdout on every action, which
  # is sometimes handy for debugging
  #before_filter :yell_name

  before_render :persist_guest_user
  before_render :add_persistent_message
  before_render :no_newrelic_for_site_admins

  after_filter :merge_flashes

	include Pundit
  include Clearance::Authentication
  include Mobvious::Rails::Controller
  include TrackEvent
  protect_from_forgery

  protected

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end

  # TODO: DEPRECATE not called
  def invitation_preview_url_with_referrer(user, referrer)
    referrer_hash = User.referrer_hash(referrer)
    invitation_preview_url({:code => user.invitation_code}.merge(@referrer_hash))
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

  # TODO: DEPRECATE not used
  def force_no_ssl
    return unless request.ssl?

    redirection_parameters = {
      :protocol   => 'http',
      :host       => request.host,
      :action     => action_name,
      :controller => controller_name
    }.reverse_merge(params)

    redirect_to redirection_parameters
    return false
  end

  def wrong_phone_validation_code_error
    "Sorry, the code you entered was invalid. Please try typing it again."
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

  def invalid_ping_logger(event, data_hash, user)
    if !user && !(["sessions", "pages"].include? params[:controller])
      Rails.logger.warn "INVALID USER PING SENT #{event}"
    end
  end

  def ping_with_device_type(event, data_hash = {}, user = nil)
    _data_hash = data_hash.merge(device_type: device_type)
    ping_without_device_type(event, _data_hash, user)

    invalid_ping_logger(event, data_hash, user)
  end

  def ping_page(page, user = nil, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page, device_type: device_type}.merge(additional_properties)
    self.ping(event, properties, user)
  end

  alias_method_chain :ping, :device_type

  # TODO: DEPRECATE there's better solutions to making debugging easier, this controller is clogged enough
  def yell_name
    puts [params[:controller], params[:action]].join('#')
  end

  def email_clicked_ping(user)
    # We rig the timestamp here so that, if this ping is present, and there's
    # also a new activity session, this ping always appears before the activity
    # session ping.
    if params[:email_type].present?
      email_ping_text = EMAIL_PING_TEXT_TYPES[params[:email_type]]
      rack_timestamp = request.env['rack.timestamp']
      event_time = (rack_timestamp || Time.now) - 5.seconds
      hsh = { email_type: email_ping_text, time: event_time }
      hsh.merge!({subject_line: URI.unescape(params[:subject_line])}) if params[:subject_line]
      ping("Email clicked", hsh, user) if email_ping_text.present?
    end
  end

  private

  alias authorize_without_guest_checks authorize


  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end

  helper_method :permitted_params

  def authorize
    return if authorize_as_potential_user
    authorize_by_explore_token

    return if authorize_as_guest
    return if authorize_to_public_board

    authorize_without_guest_checks

    refresh_activity_session(current_user)
  end

  def authorize_as_potential_user
    if session[:potential_user_id].present? && !current_user
      @_potential_user = PotentialUser.find(session[:potential_user_id])
      allowed_pathes = [activity_path, potential_user_conversions_path, ping_path]
      if @_potential_user && !allowed_pathes.include?(request.path)
        redirect_to activity_path
      end
      @_potential_user.present?
    end
  end

  def authorize_as_guest
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
          flash[:failure] = "Sorry, you don't have permission to access that part of the site."
        else
          flash[:failure] = '<a href="#" class="open_save_progress_form">Save your progress</a> to access this part of the site.'
          flash[:failure_allow_raw] = true
        end
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

  def authorize_to_public_board
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

  def authorize_by_explore_token
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

  def explore_token_allowed
    false
  end

  def find_explore_token
    params[:explore_token] || session[:explore_token]
  end

  def remember_explore_token(explore_token)
    session[:explore_token] = explore_token
  end

  def remember_explore_user(user)
    @current_user_by_explore_token = user
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

  def current_user_is_site_admin
    current_user && current_user.is_site_admin
  end

  def going_to_settings
    controller_name == "settings"
  end

  def game_not_yet_begun?
    current_user && current_user.demo.game_not_yet_begun?
  end

  def force_html_format
    request.format = :html
  end

  def hostname_without_subdomain
    request.subdomain.present? ? request.host.gsub(/^[^.]+\./, '') : request.host
  end

  def add_success(text)
    @flash_successes_for_next_request << text
  end

  def add_failure(text)
    @flash_failures_for_next_request << text
  end

  def initialize_flashes
    @flash_successes_for_next_request = []
    @flash_failures_for_next_request = []
  end

  def merge_flashes
    unless @flash_successes_for_next_request.empty?
      flash[:success] = (@flash_successes_for_next_request + [flash[:success]]).join(' ')
    end

    unless @flash_failures_for_next_request.empty?
      flash[:failure] = (@flash_failures_for_next_request + [flash[:failure]]).join(' ')
    end
  end

  def add_persistent_message
    return unless use_persistent_message?
    return unless current_user.try(:is_guest?)
    demo = current_user.try(:demo)
    return if demo && $rollout.active?(:skip_persistent_message, demo)

    keys_for_real_flashes = %w(success failure notice).map(&:to_sym)
    return if keys_for_real_flashes.any?{|key| flash[key].present?}

    flash.now[:success] = [persistent_message_or_default(current_user)]
    flash.now[:success_allow_raw] = demo.try(:allow_raw_in_persistent_message)
    @persistent_message_shown = true
  end

  def persistent_message_or_default(user)
    message_from_board = user.try(:demo).try(:persistent_message)

    if message_from_board.present?
      message_from_board
    else
      Demo.default_persistent_message
    end
  end

  def use_persistent_message?
    !(@display_get_started_lightbox) && @use_persistent_message.present?
  end

  def log_out_if_logged_in
    current_user.reset_remember_token! if current_user
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def load_characteristics(demo)
    @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(demo)
  end

  def attempt_segmentation(demo)
    if params[:segment_column].present?
      if (params[:segment_column].length > 1 and params[:segment_column].values.include?("")) or
         (params[:segment_value] and params[:segment_value].values.include?(""))
        flash.now[:failure] = "One or more of your characteristic fields is blank."
      else
        @segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], demo)
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render partial: "shared/segmentation_results", locals: {segmentation_results: @segmentation_result}, layout: false }
    end
  end

  def display_social_links
    @display_social_links = true
  end

  def persist_guest_user
    if current_user.try(:is_guest?)
      session[:guest_user] = current_user.to_guest_user_hash
    end
  end

  def self.must_be_authorized_to(page_class, options={})
    unless_symbols = options.delete(:unless)
    if_symbols = options.delete(:if)

    before_filter(options) do
      if if_symbols.present?
        if_symbols.each do |if_symbol|
          return true unless send(if_symbol)
        end
      end

      if unless_symbols.present?
        unless_symbols.each do |unless_symbol|
          return true if send(unless_symbol)
        end
      end

      unless current_user.authorized_to?(page_class)
        redirect_to '/'
        return false
      end
    end
  end

  # Note that subclasses of ApplicationController must implement their own
  # board_is_public? method if they want to use allow_guest_user, since
  # there's no single way that we decide which board is pertinent in which
  # action.

  def allow_guest_user
    @guest_user_allowed_in_action = true
  end

  def guest_user_allowed?
    @guest_user_allowed_in_action
  end

  def logged_in_as_guest?
    session[:guest_user].present? && current_user_without_guest_user.nil? && current_user_by_explore_token.nil?
  end

  def current_user_by_explore_token
    nil
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

 	def enable_miniprofiler
		if Rails.env.production_local? || (current_user && Rails.env.production? && PROFILABLE_USERS.include?(current_user.email))
			Rack::MiniProfiler.authorize_request
		end
	end


  def profiler_step(name, &block)
    Rack::MiniProfiler.step(name) do
      yield
    end
  end

	def prod_or_testing_ssl_outside_of_prod
    Rails.env.production? || $test_force_ssl
  end

  def parse_start_and_end_dates
    @sdate = params[:sdate].present? ? Date.strptime(params[:sdate], "%Y-%m-%d") : nil
    @edate =  params[:edate].present? ? Date.strptime(params[:edate], "%Y-%m-%d") : nil
  end

  def present(object, klass = nil, opts={})
    klass ||= "#{object.class}Presenter".constantize
    klass.new(object, view_context, opts)
  end
end
