class PhonesController < ApplicationController
  def update
    if params[:user][:phone_number].blank?
      current_user.update_attributes(:phone_number => "")
      flash[:success] = "OK, you won't get any more text messages from us until such time as you enter a mobile number again."
      redirect_to :back
      return
    end

    normalized_phone_number = PhoneNumber.normalize(params[:user][:phone_number])

    current_user.new_phone_number = normalized_phone_number
    current_user.new_phone_validation = "abcde"
    if current_user.save
      if request.xhr?
        render :text => current_user.phone_number
      else
        flash[:success] = "We have sent a verification to your phone. It will arrive momentarily."
        redirect_to current_user
      end
    else
      flash[:failure] = current_user.errors[:phone_number]
      redirect_to :back
    end
  end

  def validate
    if params[:user][:new_phone_validation] == current_user.new_phone_validation
      current_user.phone_number = current_user.new_phone_number
      current_user.new_phone_number = ""
      current_user.new_phone_validation = ""
      if current_user.save
        flash[:success] = "You have updated your phone number"
        redirect_to current_user and return
      end
    end
    flash[:error] = "I'm sorry--the code you entered was invalid"
    redirect_to current_user
  end
end
