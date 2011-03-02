class SessionsController < Clearance::SessionsController
  before_filter :downcase_email

  def url_after_create
    activity_path
  end

  protected

  def downcase_email
    if params[:session] && params[:session][:email].present? 
      params[:session][:email].downcase!
    end
  end
end
