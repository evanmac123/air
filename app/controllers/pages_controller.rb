class PagesController < HighVoltage::PagesController
  include TileBatchHelper

  skip_before_filter :authorize
  before_filter :allow_guest_user
  before_filter :force_html_format
  before_filter :signed_out_only_on_root
  before_filter :set_page_name
  before_filter :set_page_name_for_mixpanel
  before_filter :set_user_for_mixpanel
  before_filter :handle_disabled_pages
  after_filter :update_seeing_marketing_page_for_first_time

  layout :layout_for_page

  DISABLED_PAGES = ["customer_tiles"]

  PAGE_NAMES_FOR_MIXPANEL = {
    'welcome'        => "Marketing Page",
    'home'           => "Landing Page V. #{MP_HOMPAGE_TAG_VERSION}",
    'privacy'        => 'privacy policy',
    'terms'          => 'terms and conditions'
  }


  def show
    login_as_guest(Demo.new) unless current_user
    super
  end

  private

  def layout_for_page
    case page_name
    when 'privacy', 'terms'
      'external'
    else
      'standalone'
    end
  end

  def signed_out_only_on_root
    return unless params[:id] == 'home'
    redirect_to home_path if signed_in?
  end

  def page_name
    params[:id] || params[:action]
  end

  def set_page_name
    flash.now[:failure] ||= params[:flash][:failure] if params[:flash]
    @page_name = page_name
  end

  def set_page_name_for_mixpanel
    @page_name_for_mixpanel = page_name_for_mixpanel
  end

  def page_name_for_mixpanel
    if (name = PAGE_NAMES_FOR_MIXPANEL[page_name]).present?
      name
    else
      page_name
    end
  end

  def set_user_for_mixpanel
    @user_for_mixpanel ||= User.where(id: session[:user_id]).first
  end

  def update_seeing_marketing_page_for_first_time
    return unless current_user && current_user.respond_to?("seeing_marketing_page_for_first_time=")
    current_user.update_attributes(seeing_marketing_page_for_first_time: false)
  end

  def handle_disabled_pages
    raise ActionController::RoutingError.new("Page not Found") if DISABLED_PAGES.include?(params[:id])
  end
end
