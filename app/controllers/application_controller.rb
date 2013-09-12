class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :sniff_browser_version
  before_filter :force_ssl 
  before_filter :authorize
  before_filter :tutorial_check
  before_filter :set_delay_on_tooltips
  before_filter :initialize_flashes
  after_filter :merge_flashes

  include Clearance::Authentication
  protect_from_forgery

  protected

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end

  def invitation_preview_url_with_referrer(user, referrer)
    referrer_hash = User.referrer_hash(referrer)
    invitation_preview_url({:code => user.invitation_code}.merge(@referrer_hash))
  end
  
  def force_ssl
    if (Rails.env.development? || Rails.env.test?) && !$test_force_ssl
      return
    end
    redirect_required = false
    unless request.subdomain.present?
      redirect_required = true
    end
    unless request.ssl?
      redirect_required = true
    end
    
    if redirect_required
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
    return unless request.ssl?

    redirection_parameters = {
      :protocol   => 'http', 
      :host       => request.host, 
      :action     => action_name, 
      :controller => controller_name
    }.reverse_merge(params)

    redirect_to redirection_parameters
    return false
  end

  def wrong_phone_validation_code_error
    "Sorry, the code you entered was invalid. Please try typing it again."
  end

  private

  # See page 133 of Metaprogramming Ruby for details on how to use an "around alias"
  alias authenticate_without_game_begun_check authorize
  def authorize
    authenticate_without_game_begun_check

    return if current_user_is_site_admin || going_to_settings

    if game_not_yet_begun?
      @game_pending = true
      render "shared/game_not_yet_begun"
      return
    end

    if game_locked?
      render "shared/website_locked"
      return
    end
  end

  def current_user_is_site_admin
    current_user && current_user.is_site_admin
  end

  def going_to_settings
    controller_name == "settings"
  end

  def game_not_yet_begun?
    current_user && current_user.demo.game_not_yet_begun?
  end

  def game_locked?
    current_user && current_user.demo.website_locked?
  end

  def force_html_format
    request.format = :html
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

  def set_talking_chicken_sample_tile_done(context)
    session[:talking_chicken_sample_tile_done] = true if current_user.just_did_tutorial_sample_tile(context)
  end

  def tutorial_check
    current_user.create_tutorial_if_none_yet if current_user
  end  

  def set_delay_on_tooltips
    days_of_newbie = 2
    short_delay = 200
    long_delay = 1000
    @tooltip_delay = short_delay
    if current_user && current_user.accepted_invitation_at
      when_joined = current_user.accepted_invitation_at
      @tooltip_delay = (when_joined > days_of_newbie.days.ago) ? short_delay : long_delay
    end
  end

  def sniff_browser_version
    browser = request.env['HTTP_USER_AGENT']
    return unless browser
    result = /MSIE (\d)\.\d/.match browser
    if result
      version = result[1].to_i
      @old_browser = true if (version < 8)
      @easter_egg = true if params[:easter_egg].present?
    end
  end

  def load_characteristics(demo)
    @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(demo)
  end

  def attempt_segmentation(demo)
    #if params[:segment_column].present?
      #@segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], demo)
    #end

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

  def display_social_links
    @display_social_links = true
  end

  def self.must_be_authorized_to(page_class, options={})
    before_filter(options) do
      unless current_user.authorized_to?(page_class)
        redirect_to '/'
        return false
      end
    end
  end
end
