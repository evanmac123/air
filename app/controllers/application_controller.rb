class ApplicationController < ActionController::Base
  #before_filter :mobile_if_mobile_device

  #has_mobile_fu

  before_filter :force_ssl 
  before_filter :authenticate

  include Clearance::Authentication
  protect_from_forgery

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

  def determine_layout
    if request.xhr?
      'ajax'
    else
      'application'
    end
  end

  def force_html_format
    request.format = :html
  end

  def ipad?
    request.user_agent.to_s.downcase.include?('ipad')
  end

  def not_ipad?
    !ipad?
  end

  def mobile_if_mobile_device
    if ipad?
      session[:mobile_view] = false
    end

    if is_mobile_device? && not_ipad?
      request.format = :mobile
    end
  end

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end
end
