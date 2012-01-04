class PhonesController < ApplicationController
  def update
    if params[:user][:phone_number].blank?
      current_user.update_attributes(:phone_number => "")
      flash[:success] = "OK, you won't get any more text messages from us."
      redirect_to :back
      return
    end

    normalized_phone_number = PhoneNumber.normalize(params[:user][:phone_number])
    if current_user.phone_number == normalized_phone_number
      flash[:failure] = "We already have #{normalized_phone_number.as_pretty_phone} on record for you."
      redirect_to current_user and return
    end
    current_user.new_phone_number = normalized_phone_number
    current_user.generate_short_numerical_validation_token
    if current_user.save
      SMS.send_message current_user.new_phone_number, "Your code to verify this phone with H Engage is #{current_user.new_phone_validation}."
      flash[:success] = "We have sent a verification code to #{current_user.new_phone_number.as_pretty_phone}. It will arrive momentarily. Please enter it into the box below."
      redirect_to current_user
    else
      flash[:failure] = current_user.errors[:new_phone_number]
      redirect_to :back
    end
  end

  def validate
    if params[:user][:new_phone_validation] == current_user.new_phone_validation
      current_user.phone_number = current_user.new_phone_number
      current_user.new_phone_number = ""
      current_user.new_phone_validation = ""
      if current_user.save
        flash[:success] = "You have updated your phone number."
        redirect_to current_user and return
      end
    end
    flash[:error] = "I'm sorry--the code you entered was invalid. Please try typing it again."
    redirect_to current_user
  end
end
