class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :sniff_browser_version
  before_filter :force_ssl 
  before_filter :authorize
  before_filter :tutorial_check
  before_filter :set_delay_on_tooltips
  before_filter :initialize_flashes
  after_filter :merge_flashes

  include Clearance::Authentication
  protect_from_forgery

  layout 'old_application'

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


  def authenticate_without_game_begun_check
    def authorize
      # All this does is revert to the previously defined version of "authorize", 
      # the one before the AuthenticateWithGameBegunCheck module was included
      super
    end
  end
  
  
  module AuthenticateWithGameBegunCheck
    def authorize
      super
      if current_user && !(current_user.is_site_admin) && (controller_name != "settings") && current_user.demo.begins_at && current_user.demo.begins_at > Time.now
        @game_pending = true
        render "shared/game_not_yet_begun"
      end
    end
  end
  
  include AuthenticateWithGameBegunCheck
  
  def wrong_phone_validation_code_error
    "Sorry, the code you entered was invalid. Please try typing it again."
  end

  private

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
    keep_flashes_for_next_time
  end

  def keep_flashes_for_next_time
    # Skip if we're in settings or the admin dashboard or if we're signing in
    ref = env['HTTP_REFERER'] || ''
    return if ref.include? "/admin" 
    return if ref.include? "/settings"
    return if ref.include? "/sign_in"
    return if ref.include? "/session"
    return if current_user && current_user.tutorial_active?
    return if flash[:failure] == FailureMessages::SESSION_EXPIRED

    # Save anything we've shoved into flash using add_success or add_failure into our
    # own session variable 
    # This gets used in app/helpers/application_helper#consolidated_flash
    flash_success = flash[:success]
    flash_failure = flash[:failure]
    if flash_success 
      cookies[SavedFlashes::SUCCESS_KEY] = flash_success
      # Delete the other cookie so we don't get two at a time
      cookies.delete(SavedFlashes::FAILURE_KEY)
    end

    if flash_failure
      cookies[SavedFlashes::FAILURE_KEY] = flash_failure
      cookies.delete(SavedFlashes::SUCCESS_KEY)
    end
  end

 
  def log_out_if_logged_in
    current_user.reset_remember_token! if current_user
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def invoke_tutorial
    return nil unless current_user.reload.tutorial_active?
    first_name = Tutorial.example_search_name.split(" ").first
    example_command = current_user.demo.example_tutorial_or_default
    advance_tutorial
    @step = current_user.tutorial.current_step
    case @step
    when 0
      @show_introduction = true
    when 1
      @title = "1. Say It!"
      @instruct = "Type \"<span class='offset'>#{example_command}</span>\" and click PLAY to get 3 points"
      @highlighted = '#bar_command_wrapper'
      @x = 350
      @y = -10
      @position = "bottom left"
      @arrow_dir = "top-left"
      @flash_margin_left = "355px"  # This is so any failure messages will be offset & thereby visible
    when 2
      @title = "2. Dialog Box"
      @instruct = "This is where you'll get helpful info<br>to guide you".html_safe
      @show_next_button = true
      @highlighted = '.flash-box'
      @x = 0
      @y = 43
      @position = "center right"
      @arrow_dir = "left"
    when 3
      @title = "3. Make Connections"
      @instruct = "Click DIRECTORY to find people you know"
      @highlighted = '.nav-directory'
      @x = -141
      @y = -5
      @position = "bottom center"
      @arrow_dir = "top-right"
    when 4
      @title = "4. Find Your Friends"
      @instruct = "Just for practice, type \"<span class='offset'>#{first_name}</span>\", then click FIND!"
      @highlighted = '#search_box_wrapper'
      @x = -10
      @y = -3
      @position = "bottom center"
      @arrow_dir = "top-left"
    when 5
      @title = "5. Friend Them"
      @instruct = "Click ADD TO FRIENDS to connect with #{first_name}"
      @highlighted = '#directory_wrapper'
      @x = 0
      @y = 298
      @position = "top right"
      @arrow_dir = "left"
    when 6
      @title = "6. See Your Profile"
      @instruct = "Great! Now you're connected with Kermit. Click MY PROFILE to see him."
      @highlighted = '.nav-activity'
      @x = 0
      @y = 0
      @position = "bottom center"
      @arrow_dir = "top-center"
    when 7
      @title = "7. Have Fun Playing!"
      @instruct = "That's it! Now you know how to connect with friends and how to earn points."
      @show_finish_button = true
      @highlighted = '#following_wrapper'
      @x = 0
      @y = 128
      @position = "top left"
      @arrow_dir = "right"
    end
    return true
  end

  def advance_tutorial
    tutorial = current_user.tutorial
    path_info = @_env['PATH_INFO']
    case tutorial.current_step
    when 0 # Introductory Slide
      # They click the "next slide" button to advance
    when 1  # Say It!
      Tutorial.seed_example_user(current_user.demo)
      tutorial.bump_step if session.delete(:typed_something_in_playbox)
    when 2  # See Activity
      # They click the "next slide" button to advance
    when 3  # Click Connect
      tutorial.bump_step if path_info == "/users"
    when 4  # Search for Someone
      tutorial.bump_step if @other_users.present?
    when 5  # Follow Someone from the Search Results
      tutorial.back_up_a_step unless @other_users.present?
      tutorial.bump_step if tutorial.friend_followed_since_tutorial_start
    when 6
      tutorial.bump_step if path_info == user_path(current_user)
    when 7
      tutorial.ended_at = Time
    else
      # Do nothing
    end
      
  end
  
  def tutorial_check
    current_user.create_tutorial_if_none_yet if current_user
  end  

  def set_delay_on_tooltips
    days_of_newbie = 2
    short_delay = 200
    long_delay = 1000
    @tooltip_delay = short_delay
    if current_user && current_user.accepted_invitation_at
      when_joined = current_user.accepted_invitation_at
      @tooltip_delay = (when_joined > days_of_newbie.days.ago) ? short_delay : long_delay
    end
  end

  def sniff_browser_version
    browser = request.env['HTTP_USER_AGENT']
    return unless browser
    result = /MSIE (\d)\.\d/.match browser
    if result
      version = result[1].to_i
      @old_browser = true if (version < 8)
      @easter_egg = true if params[:easter_egg].present?
    end
  end
end
