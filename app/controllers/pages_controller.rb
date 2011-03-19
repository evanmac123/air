class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate
  before_filter :force_html_format
  before_filter :signed_out_only

  protected

  def signed_out_only
    redirect_to home_path if signed_in?
  end
end
