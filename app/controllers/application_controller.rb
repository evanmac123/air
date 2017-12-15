class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found

  before_filter :authorize!

  ##ApplicationPerformanceConcern
  before_filter :set_scout_context
  ##

  before_filter :refresh_activity_session
  before_filter :set_eager_caches

  ##AirboFlashConcern
  before_filter :initialize_flashes
  after_filter :merge_flashes
  ##

  around_filter :set_time_zone, if: :current_board

  include ActivitySessionConcern
  include CachingConcern
  include MixpanelConcern
  include FlashConcern
  include ApplicationPerformanceConcern
  include Mobvious::Rails::Controller

  ###### Airbo authentication/authorization
  include Clearance::Controller
  alias_method :clearance_authenticate, :authenticate
  alias_method :clearance_sign_in, :sign_in

  def authorize!
    unless authorized?
      deny_access(authorization_flash)
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

  def authorization_flash
    if signed_in?
      I18n.t("flashes.failure_when_not_permitted")
    else
      I18n.t("flashes.failure_when_not_signed_in_html")
    end
  end

  def render_json_access_denied
    render json: { errors: "Access Denied" }, status: 403
  end

  def current_board
    current_user.try(:demo)
  end
  ######

  private

    def set_time_zone(&block)
      Time.use_zone(current_board.timezone, &block)
    end

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
