class PasswordsController < Clearance::PasswordsController
  # We monkeypatch this stuff since the regular Clearance::PasswordsController
  # expects us to identify users by ID, when we're actually using the slug.

  before_filter :force_html_format
  before_filter :downcase_email

  layout 'external'

  def create
    @user = User.find_by_email params[:password][:email]

    # Non-existent user or a legitimate "Forgot Password" => Let Clearance handle it
    super and return if (@user.nil? or @user.claimed?)

    flash.now[:failure] = "You cannot reset a password on an unclaimed account. Please contact support@hengage.com for help."
    render :template => 'passwords/new'
  end

  def edit
    @user = ::User.find_by_slug_and_confirmation_token(params[:user_id], params[:token])
    render :template => 'passwords/edit'
  end

  def update
    @user = ::User.find_by_slug_and_confirmation_token(params[:user_id], params[:token])

    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    unless password == password_confirmation
      @user.errors[:password] = User.passwords_dont_match_error_message
    end
    
    if @user.errors.present?
      render :template => 'passwords/edit' and return
    else
      if @user.update_password(password)
        sign_in(@user)
        flash_success_after_update
        redirect_to activity_path
      else
        render :template => 'passwords/edit' and return
      end
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

  def flash_success_after_update
    add_success "Your password has been updated"
  end

  def flash_success_after_create
    # No "Signed in" message
  end
end
