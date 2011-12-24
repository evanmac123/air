class PhonesController < ApplicationController
  before_filter :find_user, :only => :create
  before_filter :verify_required_fields_present, :only => :create

  def create
    @user.update_password(params[:user][:password], params[:user][:password_confirmation])
    @user.update_attribute(:location_id, params[:user][:location_id])

    unless @user.accepted_invitation_at
      @user.join_game(params[:number], :send) 

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

  def find_user
    @user = User.find_by_slug(params[:user_id])
  end

  def verify_required_fields_present
    location_required = @user.demo.locations.count > 0

    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    all_present = password.present? && password == password_confirmation && (!location_required || params[:user][:location_id].present?)

    unless all_present
      flash[:failure] = location_required ? "Please choose a password and location." : "Please choose a password."
      redirect_to :back
      return false
    end
  end
end
