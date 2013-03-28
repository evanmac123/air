class PagesController < HighVoltage::PagesController
  FAQ_PAGES = [:faq, :faq_body, :faq_toc]

  skip_before_filter :authorize, :except => FAQ_PAGES
  before_filter :authenticate_without_game_begun_check, :only => FAQ_PAGES

  before_filter :force_html_format
  before_filter :signed_out_only, :except => FAQ_PAGES << :public_help
  before_filter :set_login_url


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
    page_name = params[:id] || params[:action]
    case page_name
    when 'privacy', 'terms'
      'external'
    when 'faq'
      'application'
    when 'faq_body', 'faq_toc'
      false
    when 'marketing'
      @body_id = "homepage"
      Shotgun.ping_page(page_name)
      'external_marketing'
    when 'waitingroom'
      'external'
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

end
