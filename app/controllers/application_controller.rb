class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :force_ssl 
  before_filter :authenticate
  before_filter :tutorial_check
  before_filter :set_delay_on_tooltips
  before_filter :initialize_flashes
  after_filter :merge_flashes

  include Clearance::Authentication
  protect_from_forgery

  layout 'old_application'

  protected

  def force_ssl
    if (Rails.env.development? || Rails.env.test?) && !$test_force_ssl
      return
    end

    unless request.ssl?
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
    if (Rails.env.development? || Rails.env.test?) && !$test_force_ssl
      return
    end

    if request.ssl?
      redirect_hostname = Rails.env.staging? ? 
                            hostname_with_subdomain : 
                            hostname_without_subdomain

      redirection_parameters = {
        :protocol   => 'http', 
        :host       => redirect_hostname, 
        :action     => action_name, 
        :controller => controller_name
      }.reverse_merge(params)

      redirect_to redirection_parameters
      return false
    end
  end

  def authenticate_with_game_begun_check
    authenticate_without_game_begun_check
    if current_user && !(current_user.is_site_admin) && current_user.demo.begins_at && current_user.demo.begins_at > Time.now
      @game_pending = true
      render "shared/game_not_yet_begun"
    end
  end

  alias_method_chain :authenticate, :game_begun_check

  def wrong_phone_validation_code_error
    "Sorry, the code you entered was invalid. Please try typing it again."
  end

  private

  def force_html_format
    request.format = :html
  end

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
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

  def invoke_tutorial
    return unless current_user.reload.tutorial_active?
    first_name = Tutorial.example_search_name.split(" ").first
    advance_tutorial
    @step = current_user.tutorial.current_step
    case @step
    when 0
      @show_introduction = true
    when 1
      @title = "1. Say It!"
      @instruct = "Type \"<span class='offset'>ate a banana</span>\" and click PLAY to get 3 points"
      @highlighted = '#bar_command_wrapper'
      @x = 350
      @y = -10
      @position = "bottom left"
      @arrow_dir = "top-left"
      @flash_margin_left = "355px"  # This is so any failure messages will be offset & thereby visible
    when 2
      @title = "2. Progress"
      @instruct = "Your activity shows up here"
      @show_next_button = true
      @highlighted = '#feed_wrapper'
      @x = -196
      @y = -5
      @position = "top center"
      @arrow_dir = "bottom-center"
    when 3
      @title = "3. Make Connections"
      @instruct = "Click on DIRECTORY to find people you know"
      @highlighted = '.nav-directory'
      @x = -141
      @y = -5
      @position = "bottom center"
      @arrow_dir = "top-right"
    when 4
      @title = "4. Find Your Friends"
      @instruct = "For example, type \"<span class='offset'>#{first_name}</span>\", then click FIND!"
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
      @instruct = "Great! Now you're connected with Kermit. Click on MY PROFILE to see him."
      @highlighted = '.nav-activity'
      @x = 0
      @y = 0
      @position = "bottom center"
      @arrow_dir = "top-center"
    when 7
      @title = "7. Have Fun Playing!"
      @instruct = "That's it! You now know how to connect with friends and how to earn points."
      @show_finish_button = true
      @highlighted = '#following_wrapper'
      @x = 0
      @y = 128
      @position = "top left"
      @arrow_dir = "right"
    end
  end

  def advance_tutorial
    tutorial = current_user.tutorial
    path_info = @_env['PATH_INFO']
    case tutorial.current_step
    when 0 # Introductory Slide
      # They click the "next slide" button to advance
    when 1  # Say It!
      Tutorial.seed_example_user(current_user.demo)
      tutorial.bump_step if tutorial.act_completed_since_tutorial_start
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
    current_user.create_tutorial_if_first_login if current_user
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
end
