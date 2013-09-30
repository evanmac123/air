class PagesController < HighVoltage::PagesController
  SIGNED_IN_OK_PAGES = [:faq, :faq_body, :faq_toc, :public_help, :static_digest]

  skip_before_filter :authorize, :except => SIGNED_IN_OK_PAGES
  before_filter :authenticate_without_game_begun_check, :only => SIGNED_IN_OK_PAGES

  before_filter :force_html_format
  before_filter :signed_out_only, :except => SIGNED_IN_OK_PAGES
  before_filter :set_login_url
  before_filter :display_social_links_if_marketing_or_waiting_room

  skip_before_filter :force_ssl, :except => SIGNED_IN_OK_PAGES
  before_filter :force_no_ssl_on_marketing

  layout :layout_for_page


  def faq
    @current_user = current_user
    render :layout => "/layouts/application"
  end

  def public_help
    render :layout => 'external'
  end

  protected

  def layout_for_page
    case page_name
    when 'privacy', 'terms'
      'external'
    when 'faq'
      'application'
    when 'faq_body', 'faq_toc'
      false
    when 'welcome'
      'standalone'
    when 'more_info'
      @body_id = "homepage"
      Shotgun.ping_page(page_name)
      'external_marketing'
    when 'pricing'
      'external_marketing'
    when 'waitingroom'
      'external'
    else
      'pages'
    end
  end

  def signed_out_only
    return if params[:id].present? && SIGNED_IN_OK_PAGES.include?(params[:id].to_sym)
    redirect_to home_path if signed_in?
  end

  def set_login_url
    @login_url = if Rails.env.staging? || Rails.env.production?
                   session_url(:protocol => 'https', :host => hostname_with_subdomain)
                 else
                   session_path
                 end
  end

  def display_social_links_if_marketing_or_waiting_room
    display_social_links if %w(waitingroom more_info pricing).include?(params[:id])
  end

  def page_name
    page_name = params[:id] || params[:action]
  end

  def force_no_ssl_on_marketing
    return unless page_name == 'welcome' || page_name == 'more_info' || page_name == 'pricing'
    force_no_ssl
  end
end
