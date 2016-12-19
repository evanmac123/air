class ApplicationController < ActionController::Base
  protect_from_forgery

  ##AirboSecurityHelper
  before_filter :force_ssl
  before_filter :disable_mime_sniffing
  before_filter :disable_framing
  ##

  ##AirboAuthorizationHelper =>
  before_filter :authorize_with_onboarding_auth_hash
  before_filter :authorize
  before_filter :set_show_conversion_form_before_this_request
  before_render :persist_guest_user
  before_render :no_newrelic_for_site_admins
  ##

  ##AirboFlashHelper =>
  before_filter :initialize_flashes
  before_render :add_persistent_message
  after_filter :merge_flashes
  ##

  before_filter :enable_miniprofiler #NOTE on by default in development

  ###### Airbo authentication/authorizaiton`
	include Pundit
  alias_method :pundit_authorize, :authorize
  include Clearance::Authentication
  alias_method :clearance_authenticate, :authorize
  include AirboAuthorizationHelper

  #This should be renamed to authenticate
  def authorize
    return if authenticate_as_potential_user
    return if authenticate_by_explore_token
    return if authenticate_as_guest
    return if authenticate_to_public_board
    clearance_authenticate
    refresh_activity_session(current_user)
  end
  ######

  include AirboActivitySessionHelper
  include AirboSecurityHelper
  include AirboPingsHelper
  include AirboFlashHelper
  include Mobvious::Rails::Controller

  # TODO: Can we find a solution that does not require dev methods (miniprofiler, newrelic) in AppController??
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

  def present(object, klass = nil, opts={})
    klass ||= "#{object.class}Presenter".constantize
    klass.new(object, view_context, opts)
  end

  private

    ##deprecate =>
    def permitted_params
      @permitted_params ||= PermittedParams.new(params, current_user)
    end

    helper_method :permitted_params


    ##MOVE TO SPECIFIC CONTROLLERS =>
    def wrong_phone_validation_code_error
      "Sorry, the code you entered was invalid. Please try typing it again."
    end

    def log_out_if_logged_in
      current_user.reset_remember_token! if current_user
      cookies.delete(:remember_token)
      self.current_user = nil
    end

    def load_characteristics(demo)
      @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(demo)
    end

    def attempt_segmentation(demo)
      if params[:segment_column].present?
        if (params[:segment_column].length > 1 and params[:segment_column].values.include?("")) or
           (params[:segment_value] and params[:segment_value].values.include?(""))
          flash.now[:failure] = "One or more of your characteristic fields is blank."
        else
          @segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], demo)
        end
      end

      respond_to do |format|
        format.html { redirect_to :back }
        format.js   { render partial: "shared/segmentation_results", locals: {segmentation_results: @segmentation_result}, layout: false }
      end
    end

    def parse_start_and_end_dates
      @sdate = params[:sdate].present? ? Date.strptime(params[:sdate], "%Y-%m-%d") : nil
      @edate =  params[:edate].present? ? Date.strptime(params[:edate], "%Y-%m-%d") : nil
    end
end
