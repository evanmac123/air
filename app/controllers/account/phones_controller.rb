class Account::PhonesController < ApplicationController
  def edit
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
end
