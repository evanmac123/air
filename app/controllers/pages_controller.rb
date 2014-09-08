class PagesController < HighVoltage::PagesController
  SIGNED_IN_OK_PAGES = [:faq, :faq_body, :faq_toc, :public_help, :static_digest, :static_followup]

  skip_before_filter :authorize, :except => SIGNED_IN_OK_PAGES
  before_filter :authorize_without_guest_checks, :only => SIGNED_IN_OK_PAGES
  before_filter :force_html_format
  before_filter :signed_out_only_on_root
  before_filter :set_login_url
  before_filter :set_new_board_url
  before_filter :display_social_links_if_marketing_page
  before_filter :set_page_name
  before_filter :ping_if_marketing_page

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
    when 'welcome', 'product'
      'standalone'
    when 'more_info', 
      @body_id = "homepage"
      'external_marketing'
    when 'pricing', 'asha', 'heineken', 'miltoncat', 'fujifilm', 'customer_tiles'
      'external_marketing'
    else
      'pages'
    end
  end

  def signed_out_only_on_root
    return unless params[:id] == 'welcome'
    redirect_to home_path if signed_in?
  end

  def set_login_url
    @login_url = if Rails.env.staging? || Rails.env.production?
                   session_url(:protocol => 'https', :host => hostname_with_subdomain)
                 else
                   session_path
                 end
  end

  def set_new_board_url
    @new_board_url = if Rails.env.production?
                       boards_url(protocol: 'https', host: hostname_with_subdomain)
                     else
                       boards_url
                     end
  end

  def display_social_links_if_marketing_page
    display_social_links if %w(more_info pricing asha miltoncat heineken fujifilm customer_tiles).include?(params[:id])
  end

  def page_name
    page_name = params[:id] || params[:action]
  end

  def force_no_ssl_on_marketing
    return unless page_name == 'welcome' || page_name == 'more_info' || page_name == 'pricing'
    force_no_ssl
  end

  def set_page_name
    flash.now[:failure] ||= params[:flash][:failure] if params[:flash]
    @page_name = page_name
  end

  def ping_if_marketing_page
    if page_name == 'welcome'
      user =  if session[:user_id]
                User.where(id: session[:user_id]).first
              else
                GuestUser.where(id: session[:guest_user_id]).first
              end
      properties = {has_ever_logged_in: (user ? true : false), \
                    ping_time: Time.new.strftime("%H:%M:%S"), \
                    url: request.original_url, \
                    user_type: (user ? user.highest_ranking_user_type : nil)}
      properties.merge!({distinct_id: session[:session_id]}) unless user
      ping_page("Marketing Page", user, properties)
    end
  end
end
