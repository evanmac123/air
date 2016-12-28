class PasswordsController < ApplicationController
  # TODO: Rewrite this controller to inherit cleanly from Clearance::PasswordsController
  skip_before_filter :require_login,
    only: [:create, :edit, :new, :update],
    raise: false
  skip_before_filter :authorize,
    only: [:create, :edit, :new, :update],
    raise: false
  before_filter :ensure_existing_user, only: [:edit, :update]
  before_filter :force_html_format
  before_filter :downcase_email

  layout 'external'

  def create
    @user = User.find_by_email params[:password][:email]

    if @user.nil?
      flash.now[:failure] = "We're sorry, we can't find your email address in our records. Please contact support@airbo.com for assistance."
      render :template => 'passwords/new'
    elsif @user.unclaimed?
      flash.now[:failure] = "We're sorry, you need to join Airbo before you can reset your password. Please contact support@airbo.com for assistance."
      render :template => 'passwords/new'
    else
      @user.forgot_password!
      Mailer.delay.change_password(@user.id)
      render :template => 'passwords/create'
    end
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


  private

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

    def flash_failure_after_create
      flash.now[:failure] = "We're sorry, we can't find your email address in our records. Please contact <a href=\"mailto:support@airbo.com\">support@airbo.com</a> for assistance."
      flash.now[:failure_allow_raw] = true
    end

    def force_html_format
      request.format = :html
    end
end
