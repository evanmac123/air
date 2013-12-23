class ApplicationController < ActionController::Base
  FLASHES_ALLOWING_RAW = %w(notice)

  before_filter :force_ssl 
  before_filter :authorize
  before_filter :initialize_flashes
  before_filter :set_show_conversion_form_before_this_request

  before_render :persist_guest_user

  after_filter :merge_flashes

  include Clearance::Authentication
  include Mobvious::Rails::Controller
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

  def tile_batch_size
    if first_tile_batch
      2 * tile_batch_size_increment
    else
      base_batch_size + tile_batch_size_increment - (base_batch_size % tile_batch_size_increment)
    end
  end

  def first_tile_batch
    params[:base_batch_size].nil? || params[:base_batch_size].empty?
  end

  def base_batch_size
    base_batch_size = params[:base_batch_size].to_i
  end

  def set_show_conversion_form_before_this_request
    session[:conversion_form_shown_before_this_request] = session[:conversion_form_shown_already]
  end

  def show_conversion_form_provided_that(allow_reshow = false)
    # uncommenting this next line is handy for e.g. working on style or copy of 
    # conversion form, as it will make the conversion form always pop.
    #return(@show_conversion_form = true)

    return if session[:conversion_form_shown_already] && !(allow_reshow)
    return unless current_user && current_user.is_guest?

    @show_conversion_form = yield
    session[:conversion_form_shown_already] = @show_conversion_form
  end

  private

  alias authenticate_without_game_begun_check authorize
  def authorize
    if logged_in_as_guest?
      if guest_user_allowed?
        return
      else
        flash[:failure] = 'That function is restricted to signed-in users. If you already have an account with H.Engage, <a href="/session/new">click here to sign in</a>.'
        flash[:failure_allow_raw] = true
        redirect_to public_activity_path(claimed_guest_user.demo.public_slug)
        return
      end
    end

    if current_user.nil? && guest_user_allowed? && params[:public_slug]
      login_as_guest(params[:public_slug])
      return
    end

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

  def claimed_guest_user
    GuestUser.find(session[:guest_user][:id])
  end

  def login_as_guest(public_slug)
    demo = Demo.where(public_slug: public_slug).first
    session[:guest_user] = {demo_id: demo.id}
  end

  def current_user_with_guest_user
    return current_user_without_guest_user unless guest_user_allowed?

    if (user = current_user_without_guest_user)
      return user
    end

    if logged_in_as_guest?
      @_guest_user ||= find_or_create_guest_user
      @_guest_user
    else
      nil
    end
  end
  alias_method_chain :current_user, :guest_user

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

  def persist_guest_user
    if current_user.try(:is_guest?)
      session[:guest_user] = current_user.to_guest_user_hash
    end
  end

  def self.must_be_authorized_to(page_class, options={})
    before_filter(options) do
      unless current_user.authorized_to?(page_class)
        redirect_to '/'
        return false
      end
    end
  end

  def allow_guest_user
    @guest_user_allowed = true
  end

  def guest_user_allowed?
    @guest_user_allowed
  end

  def logged_in_as_guest?
    session[:guest_user].present? && current_user_without_guest_user.nil?
  end

  def find_or_create_guest_user
    if session[:guest_user][:id].present?
      guest_user = GuestUser.find(session[:guest_user][:id])
      if params[:public_slug]
        board = Demo.find_by_public_slug(params[:public_slug])
        unless guest_user.demo_id == board.id
          guest_user.demo = board
          guest_user.save!
        end
      end
      guest_user
    else
      GuestUser.create!(session[:guest_user])
    end
  end
end
