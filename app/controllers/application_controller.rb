class ApplicationController < ActionController::Base
  #before_filter :mobile_if_mobile_device

  #has_mobile_fu

  before_filter :authenticate

  include Clearance::Authentication
  protect_from_forgery

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
end
