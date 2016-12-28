class LoggedInUserPasswordsController < UserBaseController
  # TODO: Get rid of this controller and user Clearance::PasswordsController after we get rid of our monkeypatched PasswordsController and replace it with a cleaner augmentation of the Clearance::PasswordsController.  Move flashes to I18n.

  def update
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    if update_password?(password, password_confirmation)
      flash[:success] = "Your password has been updated"
    else
      if current_user.errors[:password].empty? || password.blank?
        flash[:failure] = "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
      else
        flash[:failure] = "Sorry, we couldn't set your password to that: it #{current_user.errors[:password].to_sentence}."
      end
    end

    sign_in(current_user)
    redirect_to edit_account_settings_path
  end

  private

    def update_password?(password, password_confirmation)
      password == password_confirmation && current_user.update_password(password)
    end
end
