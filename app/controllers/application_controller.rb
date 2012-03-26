class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :force_ssl 
  before_filter :authenticate
  before_filter :tutorial_check
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
    when 1
      @title = "Say It!"
      @instruct = 'Enter "ate a banana" and click Play to get 3 points'
      @inverted = true
      @highlighted = '.bar_command'
      @x = 350
      @y = -10
      @position = "bottom left"
    when 2
      @title = "Progress"
      @instruct = "Your activity shows up here"
      @show_next_button = true
      @highlighted = '.feeds'
      @x = 645
      @y = -10
      @position = "top left"
    when 3
      @title = "Connect with Coworkers"
      @instruct = "Click here to find people you know"
      @inverted = true
      @highlighted = '.nav-directory'
      @x = 0
      @y = -10
      @position = "bottom center"
    when 4
      @title = "Find Coworkers"
      @instruct = "For example, type '#{first_name}', then click FIND!"
      @inverted = true
      @highlighted = '#search-box'
      @x = -80
      @y = -24
      @position = "bottom center"
    when 5
      @title = "Follow"
      @instruct = "Click 'Follow' to befriend #{first_name}"
      @highlighted = '.directory'
      @x = 0
      @y = 100
      @position = "middle right"
    when 6
      @title = "See Your Friends"
      @instruct = "Click 'My Profile' to see who's following you"
      @show_finish_button = true
      @inverted = true
      @highlighted = '.nav-activity'
      @x = 0
      @y = -10
      @position = "bottom center"
    end
  end

  def advance_tutorial
    tutorial = current_user.tutorial
    path_info = @_env['PATH_INFO']
    case tutorial.current_step
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
      # Do nothing
    else
      # Do nothing
    end
      
  end
  
  def tutorial_check
    current_user.create_tutorial_if_first_login if current_user
  end  
  
end
