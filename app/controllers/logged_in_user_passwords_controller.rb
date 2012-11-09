class LoggedInUserPasswordsController < ApplicationController
  def update
    user = current_user
    password, password_confirmation = [params[:user][:password], params[:user][:password_confirmation]]

    if password == password_confirmation && user.update_password(password)
      flash[:success] = "Your password has been updated"
    else
      flash[:failure] = if user.errors[:password].empty? || password.blank?
                          "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
                        else
                          "Sorry, we couldn't set your password to that: it #{user.errors[:password].to_sentence}."
                        end
    end

    redirect_to :back
  end
end
