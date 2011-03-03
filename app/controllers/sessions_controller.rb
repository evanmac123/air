class SessionsController < Clearance::SessionsController
  before_filter :downcase_email

  def create
    @user = ::User.authenticate(params[:session][:email],
                                params[:session][:password])
    if @user.nil?
      flash_failure_after_create
      render :template => 'sessions/new'
    else
      sign_in(@user)
      flash_success_after_create
      redirect_back_or(url_after_create)
    end
  end

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
