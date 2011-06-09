class PhonesController < ApplicationController
  before_filter :verify_password_chosen, :only => :create

  def create
    @user = User.find_by_slug(params[:user_id])
    @user.update_password(params[:phone][:user][:password], params[:phone][:user][:password_confirmation])
    @user.join_game(params[:phone][:number], :send)

    flash[:success] = "Welcome to the game! Players' activity is below to the left. The scoreboard is below to the right."
    redirect_to "/activity"
  end

  def update
    current_user.phone_number = PhoneNumber.normalize(params[:user][:phone_number])
    if current_user.save
      if request.xhr?
        render :text => current_user.phone_number
      else
        flash[:success] = "Your mobile number was updated."
        redirect_to current_user
      end
    else
      flash[:failure] = "Problem updating your mobile number: #{current_user.errors.full_messages}"
      render :edit
    end
  end

  private

  def verify_password_chosen
    password = params[:phone][:user][:password]
    password_confirmation = params[:phone][:user][:password_confirmation]
    unless password.present? && password == password_confirmation
      flash[:failure] = "Please choose a password."
      redirect_to :back
      return false
    end
  end
end
