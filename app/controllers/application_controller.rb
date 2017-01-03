class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authorize!
  before_filter :refresh_activity_session

  ##AirboSecurityHelper
  before_filter :force_ssl
  before_filter :disable_mime_sniffing
  before_filter :disable_framing
  ##

  ##AirboFlashHelper
  before_filter :initialize_flashes
  after_filter :merge_flashes
  ##

  ##MiniprofilerHelper
  before_filter :enable_miniprofiler
  ##

  include ActivitySessionConcern
  include SecurityConcern
  include MixpanelConcern
  include FlashConcern
  include MiniprofilerConcern
  include Mobvious::Rails::Controller

  ###### Airbo authentication/authorizaiton
	include Pundit
  alias_method :pundit_authorize, :authorize

  include Clearance::Controller
  alias_method :clearance_authenticate, :authenticate
  alias_method :clearance_sign_in, :sign_in

  def authorize!
    unless authorized?
      redirect_to root_path
    end
  end

  def authorized?
    return true
  end

  def sign_in(user, remember_me = false)
    clearance_sign_in(user) do |status|
      if status.success?
        set_remember_user(remember_me)
        session.delete(:guest_user)
      end
    end
  end

  def set_remember_user(remember_me)
    if remember_me
      cookies.permanent[:remember_me] = remember_me
    else
      cookies.delete(:remember_me)
    end
  end
  ######

  private

    def present(object, klass = nil, opts={})
      klass ||= "#{object.class}Presenter".constantize
      klass.new(object, view_context, opts)
    end

    def permitted_params
      @permitted_params ||= PermittedParams.new(params, current_user)
    end

    def not_found
      render file: "#{Rails.root}/public/404", status: :not_found, layout: false, formats: [:html]
    end
end
