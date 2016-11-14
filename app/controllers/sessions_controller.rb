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
      if params[:demo_id]
        @user.move_to_new_demo(params[:demo_id])
      end

      flash_success_after_create
      flash_login_announcement
      flash[:mp_track_logged_in] = "logged in"
      redirect_back_or(url_after_create)
    end
  end

  def destroy
    sign_out
    redirect_to(url_after_destroy)
  end

  def url_after_create
    return params[:url_after_create] if params[:url_after_create].present?

    if current_user.is_client_admin? || current_user.is_site_admin?
      explore_path
    else
      activity_path
    end
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
