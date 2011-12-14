class PhonesController < ApplicationController
  before_filter :verify_password_chosen, :only => :create

  def create
    @user = User.find_by_slug(params[:user_id])
    @user.update_password(params[:phone][:user][:password], params[:phone][:user][:password_confirmation])

    unless @user.accepted_invitation_at
      @user.join_game(params[:phone][:number], :send) 

      flash[:success] = "Welcome to the game! Players' activity is below to the left. The scoreboard is below to the right."
    end

    redirect_to "/activity"
  end

  def update
    if params[:user][:phone_number].blank?
      current_user.update_attributes(:phone_number => "")
      flash[:success] = "OK, you won't get any more text messages from us until such time as you enter a mobile number again."
      redirect_to :back
      return
    end

    normalized_phone_number = PhoneNumber.normalize(params[:user][:phone_number])

    current_user.phone_number = normalized_phone_number
    if current_user.save
      if request.xhr?
        render :text => current_user.phone_number
      else
        flash[:success] = "Your mobile number was updated."
        redirect_to current_user
      end
    else
      flash[:failure] = "Problem updating your mobile number: #{current_user.errors.full_messages}"
      redirect_to :back
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
