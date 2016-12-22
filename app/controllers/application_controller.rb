class ApplicationController < ActionController::Base
  protect_from_forgery

  ##AirboSecurityHelper
  before_filter :force_ssl
  before_filter :disable_mime_sniffing
  before_filter :disable_framing
  ##

  ##AirboAuthenticationHelper or BaseClass =>
  before_filter :authenticate
  ##

  ##Defined on BaseClass =>
  before_filter :authorize!
  ##

  ##AirboFlashHelper =>
  before_filter :initialize_flashes
  after_filter :merge_flashes
  ##

  before_filter :enable_miniprofiler #NOTE on by default in development

  include AirboActivitySessionHelper
  include AirboSecurityHelper
  include AirboPingsHelper
  include AirboFlashHelper
  include Mobvious::Rails::Controller

  ###### Airbo authentication/authorizaiton
	include Pundit
  alias_method :pundit_authorize, :authorize
  include Clearance::Authentication
  alias_method :clearance_authenticate, :authorize
  include AirboAuthenticationHelper

  def authenticate
    return true
  end

  def authorize!
    unless authorized?
      redirect_to root_path
    end
  end

  def authorized?
    return true
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

    def enable_miniprofiler
      if Rails.env.production_local? || (current_user && Rails.env.production? && PROFILABLE_USERS.include?(current_user.email))
        Rack::MiniProfiler.authorize_request
      end
    end

    def profiler_step(name, &block)
      Rack::MiniProfiler.step(name) do
        yield
      end
    end
end
