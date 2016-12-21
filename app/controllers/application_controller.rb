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
  before_filter :authorize
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

  ###### Airbo authentication/authorizaiton`
	include Pundit
  alias_method :pundit_authorize, :authorize
  include Clearance::Authentication
  alias_method :clearance_authenticate, :authorize
  include AirboAuthenticationHelper
  ######

  def authorize
    true
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

    def decide_if_tiles_can_be_done(satisfiable_tiles)
      @all_tiles_done = satisfiable_tiles.empty?
      @no_tiles_to_do = current_user.demo.tiles.active.empty?
    end

    def not_found
      render file: "#{Rails.root}/public/404", status: :not_found, layout: false, formats: [:html]
    end
end
