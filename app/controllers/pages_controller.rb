class PagesController < HighVoltage::PagesController
  FAQ_PAGES = [:faq, :faq_body, :faq_toc]

  skip_before_filter :authorize, :except => FAQ_PAGES
  before_filter :authenticate_without_game_begun_check, :only => FAQ_PAGES
  before_filter :force_hostname_with_subdomain
  skip_before_filter :force_ssl, :except => FAQ_PAGES
  before_filter :force_no_ssl_on_marketing, :only => [:show]

  before_filter :force_html_format
  before_filter :signed_out_only, :except => FAQ_PAGES
  before_filter :set_login_url


  layout :layout_for_page

  def faq
    @current_user = current_user
    render :layout => "/layouts/application"
  end

  protected

  def layout_for_page
    case params[:id]
    when 'privacy', 'terms'
      'external'
    when 'faq'
      'application'
    when 'faq_body', 'faq_toc', 'marketing'
      false
    else
      'pages'
    end
  end

  def signed_out_only
    redirect_to home_path if signed_in?
  end

  def set_login_url
    @login_url = if Rails.env.staging? || Rails.env.production?
                   session_url(:protocol => 'https', :host => hostname_with_subdomain)
                 else
                   session_path
                 end
  end

  def force_no_ssl_on_marketing
    return unless params[:id] == 'marketing'
    if request.ssl?
      force_no_ssl
    end
  end

  def force_hostname_with_subdomain
    return if request.subdomain.present? || request.local?
    redirect_to(host: hostname_with_subdomain)
    false
  end
end
