class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate, :except => [:faq, :faq_body, :faq_toc]
  skip_before_filter :force_ssl, :except => [:faq, :faq_body, :faq_toc]

  before_filter :force_html_format
  before_filter :signed_out_only, :except => [:faq, :faq_body, :faq_toc]
  before_filter :set_login_url

  def terms
    render :layout => "/layouts/external"
  end
  
  def privacy
    render :layout => "/layouts/external"
  end
  
  
  def faq
    render :layout => "/layouts/application"
  end
  
  def faq_body
    render :layout => false
  end
  
  def faq_toc
    render :layout => false
  end
  
  protected

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
