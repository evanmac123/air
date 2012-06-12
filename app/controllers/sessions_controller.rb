class SessionsController < Clearance::SessionsController
  before_filter :downcase_email

  layout "external" 

  def new
    super
  end

  def create
    @user = ::User.authenticate(params[:session][:email],
                                params[:session][:password])
    if @user.nil?
      flash_failure_after_create
      render :template => 'sessions/new'
    else
      sign_in(@user, params[:session][:remember_me])
      flash_success_after_create
      flash_login_announcement
      flash[:mp_track_logged_in] = "logged in"
      redirect_back_or(url_after_create)
    end
  end

  def url_after_create
    activity_path(:format => :html)
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

  def flash_success_after_create
    # No "Signed in" message
  end

  def flash_failure_after_create
    flash[:failure] = "Sorry, that's an invalid username or password."
  end
end
