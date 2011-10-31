class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate
  skip_before_filter :force_ssl

  before_filter :force_html_format
  before_filter :signed_out_only
  before_filter :set_login_url

  layout :layout_for_page

  protected

  def layout_for_page
    if params[:id] == 'new_marketing'
      'new_pages'
    elsif params[:id] == 'yahoo'
      @use_yahoo_logo = true
      @new_appearance = true
      'application'
    else
      'pages'
    end
  end

  def signed_out_only
    redirect_to home_path if (signed_in? && params[:id] != 'yahoo')
  end

  def set_login_url
    @login_url = if Rails.env.staging? || Rails.env.production?
                   session_url(:protocol => 'https', :host => hostname_with_subdomain)
                 else
                   session_path
                 end
  end
end
