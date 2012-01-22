class PasswordsController < Clearance::PasswordsController
  # We monkeypatch this stuff since the regular Clearance::PasswordsController
  # expects us to identify users by ID, when we're actually using the slug.

  before_filter :force_html_format
  before_filter :downcase_email
  layout 'external'



  def edit
    @user = ::User.find_by_slug_and_confirmation_token(
                   params[:user_id], params[:token])
    render :template => 'passwords/edit'
  end

  def update
    @user = ::User.find_by_slug_and_confirmation_token(
                   params[:user_id], params[:token])

    if @user.update_password(params[:user][:password],
                             params[:user][:password_confirmation])
      sign_in(@user)
      flash_success_after_update
      redirect_to(url_after_update)
    else
      render :template => 'passwords/edit'
    end
  end


  protected

  def forbid_non_existent_user
    unless ::User.find_by_slug_and_confirmation_token(
                  params[:user_id], params[:token])
      if params[:token]
        flash[:failure] = "For security reasons, you can use each password reset link just once. If you'd like to reset your password again, please request a new link from this form."
        redirect_to new_password_path
      else
        raise ActionController::Forbidden, "non-existent user"
      end
    end
  end

  def downcase_email
    if params[:password] && params[:password][:email]
      params[:password][:email].downcase!
    end
  end



  def flash_success_after_create
    # No "Signed in" message
  end
end
