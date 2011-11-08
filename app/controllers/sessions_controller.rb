class SessionsController < Clearance::SessionsController
  before_filter :downcase_email

  def new
    @new_appearance = true
    super
  end

  def create
    @new_appearance = true
    @user = ::User.authenticate(params[:session][:email],
                                params[:session][:password])
    if @user.nil?
      flash_failure_after_create
      render :template => 'sessions/new'
    else
      sign_in(@user)
      flash_success_after_create
      flash_login_announcement
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

  def flash_login_announcement
    if (login_announcement = @user.demo.login_announcement).present?
      flash[:notice] = login_announcement
    end
  end
end
