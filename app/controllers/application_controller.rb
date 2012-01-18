class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :force_ssl 
  before_filter :authenticate

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

  def authenticate_with_game_begun_check
    authenticate_without_game_begun_check
    if current_user && !(current_user.is_site_admin) && current_user.demo.begins_at && current_user.demo.begins_at > Time.now
      @new_appearance = true
      render "shared/game_not_yet_begun"
    end
  end

  alias_method_chain :authenticate, :game_begun_check

  private

  def force_html_format
    request.format = :html
  end

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end  
  
  def add_success(text)
    @flash_successes << text
  end

  def add_failure(text)
    @flash_failures << text
  end

  def initialize_flashes
    @flash_successes = []
    @flash_failures = []
  end

  def merge_flashes
    unless @flash_successes.empty?
      flash[:success] = @flash_successes.join(' ')
    end

    unless @flash_failures.empty?
      flash[:failure] = @flash_failures.join(' ')
    end
  end
end
