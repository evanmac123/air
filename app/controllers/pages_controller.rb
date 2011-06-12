class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate
  before_filter :force_html_format
  before_filter :signed_out_only

  layout :layout_for_page

  protected

  def layout_for_page
    if params[:id] == 'new_marketing'
      'new_pages'
    else
      'pages'
    end
  end

  def signed_out_only
    redirect_to home_path if signed_in?
  end
end
