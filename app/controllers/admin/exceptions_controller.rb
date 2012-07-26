class Admin::ExceptionsController < AdminBaseController
  skip_before_filter :authorize, :require_site_admin
  def show
    @something = "for nothing"
    raise "No Worries--just Testing the Exception Notifier system (Airbrake)"
  end
end
