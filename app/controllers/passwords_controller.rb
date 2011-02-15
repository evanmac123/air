class PasswordsController < Clearance::PasswordsController
  # We monkeypatch this stuff since the regular Clearance::PasswordsController
  # expects us to identify users by ID, when we're actually using the slug.

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

  def forbid_non_existent_user
    unless ::User.find_by_slug_and_confirmation_token(
                  params[:user_id], params[:token])
      raise ActionController::Forbidden, "non-existent user"
    end
  end
end
