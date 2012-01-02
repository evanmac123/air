class PhonesController < ApplicationController
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
      flash[:failure] = current_user.errors[:phone_number]
      redirect_to :back
    end
  end
end
