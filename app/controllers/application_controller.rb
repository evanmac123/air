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
  before_filter :initialize_flashes
  before_filter :set_show_conversion_form_before_this_request
  before_filter :load_boards_for_switching_and_managing

  # This prints the controller and action to stdout on every action, which
  # is sometimes handy for debugging
  # before_filter :yell_name

  before_render :persist_guest_user

  after_filter :merge_flashes

  include Clearance::Authentication
  include Mobvious::Rails::Controller
  include TrackEvent

  protect_from_forgery

  protected

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end

  def invitation_preview_url_with_referrer(user, referrer)
    referrer_hash = User.referrer_hash(referrer)
    invitation_preview_url({:code => user.invitation_code}.merge(@referrer_hash))
  end
  
  def force_ssl
    if (Rails.env.development? || Rails.env.test?) && !$test_force_ssl
      return
    end
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

    @show_conversion_form = yield
    session[:conversion_form_shown_already] = @show_conversion_form
  end

  def ping_with_device_type(event, data_hash = {}, user = nil)
    _data_hash = data_hash.merge(device_type: device_type)
    ping_without_device_type(event, _data_hash, user)
  end

  def ping_page(page, user = nil, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page, device_type: device_type}.merge(additional_properties)
    self.ping(event, properties, user)
  end

  alias_method_chain :ping, :device_type

  def yell_name
    puts [params[:controller], params[:action]].join('#')
  end

  def email_clicked_ping user
    if params[:email_type].present?
      email_ping_text = EMAIL_PING_TEXT_TYPES[params[:email_type]]
      ping("Email clicked", { test: email_ping_text }, user) if email_ping_text.present?
    end
  end
  
  private

  alias authorize_without_guest_checks authorize

  def authorize
    authorize_by_explore_token

    return if authorize_as_guest
    return if authorize_to_public_board

    authorize_without_guest_checks

    refresh_activity_session(current_user)

    return if current_user_is_site_admin || going_to_settings

    if game_locked?
      render "shared/website_locked"
      return
    end
  end

  def authorize_as_guest
    if logged_in_as_guest?
      if guest_user_allowed?
        board = find_current_board # must be implemented in subclass
        unless board && board.is_public
          public_board_not_found
        end

        refresh_activity_session(current_user)
        return true
      else
        flash[:failure] = '<a href="#" class="open_save_progress_form">Save your progress</a> to access this part of the site.'
        flash[:failure_allow_raw] = true
        redirect_to public_activity_path(claimed_guest_user.demo.public_slug)
        return true
      end
    end
  end

  def login_as_guest(demo)
    session[:guest_user] = {demo_id: demo.id}
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
    remember_explore_user(UserWithoutBoardSwitching.new(user))
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
    return if user.nil?
    #session things for marketing page ping
    if user.is_a? User
      session[:user_id] = user.id 
      session[:guest_user_id] = nil
    elsif user.is_a? GuestUser
      session[:guest_user_id] = user.id 
      session[:user_id] = nil
    end
    
    baseline = user.last_session_activity_at.to_i || 0
    difference = Time.now.to_i - baseline

    user.last_session_activity_at = Time.now
    user.save!

    if difference >= ACTIVITY_SESSION_THRESHOLD
      ping('Activity Session - New', {}, user)
    end
  end

  def claimed_guest_user
    GuestUser.find(session[:guest_user][:id])
  end

  def public_board_not_found
    render 'shared/public_board_not_found', layout: 'external_marketing'
  end

  def current_user_with_guest_user
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

  def game_locked?
    current_user && current_user.demo.website_locked?
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

    if current_user
      @_user_flashes = current_user.flashes_for_next_request || {}
      current_user.update_attributes(:flashes_for_next_request => nil) if current_user.flashes_for_next_request
    end
  end

  def merge_flashes
    unless @flash_successes_for_next_request.empty?      
      flash[:success] = (@flash_successes_for_next_request + [flash[:success]]).join(' ')
    end

    unless @flash_failures_for_next_request.empty?
      flash[:failure] = (@flash_failures_for_next_request + [flash[:failure]]).join(' ')
    end
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
    #if params[:segment_column].present?
      #@segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], demo)
    #end

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
        unless guest_user.demo_id == board.id
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
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end

  def decide_if_tiles_can_be_done(satisfiable_tiles)
    @all_tiles_done = satisfiable_tiles.empty?
    @no_tiles_to_do = current_user.demo.tiles.active.empty?
  end

  def load_boards_for_switching_and_managing
    return unless current_user && !(current_user.is_guest?)
    
    @boards_to_switch_to = if current_user.is_site_admin
                             Demo.alphabetical
                           else 
                              current_user.demos.alphabetical
                           end

    @boards_as_admin = current_user.boards_as_admin
    @boards_as_regular_user = current_user.boards_as_regular_user
    @has_only_one_board = current_user.has_only_one_board?
    @muted_followup_boards = current_user.muted_followup_boards
    @muted_digest_boards = current_user.muted_digest_boards
  end
end
