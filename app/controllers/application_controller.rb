class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  before_filter :authorize!

  ##ApplicationPerformanceConcern
  before_filter :enable_miniprofiler
  before_filter :set_apm_custom_contexts
  ##

  before_filter :refresh_activity_session
  before_filter :set_eager_caches

  ##AirboSecurityConcern
  before_filter :force_ssl
  before_filter :disable_mime_sniffing
  before_filter :disable_framing
  ##

  ##AirboFlashConcern
  before_filter :initialize_flashes
  after_filter :merge_flashes
  ##

  include ActivitySessionConcern
  include CachingConcern
  include SecurityConcern
  include MixpanelConcern
  include FlashConcern
  include ApplicationPerformanceConcern
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

    def not_found(flash_message = 'flashes.failure_resource_not_found')
      respond_to do |format|
        format.html {
          flash[:failure] = I18n.t(flash_message)
          redirect_to root_path
        }
        format.any { head :not_found }
      end
    end

end
