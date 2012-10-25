class Users::PhoneVerificationController < ApplicationController

  before_filter :authorize
  
  def create
    if current_user.new_phone_number.present?
      current_user.send_new_phone_validation_token
      add_success "We have resent your phone validation code to #{current_user.new_phone_number.try(:as_pretty_phone)}."
    redirect_to :back
    else
      add_failure "Please provide your phone number below"
      redirect_to edit_account_settings_path
    end
  end

  def destroy
    current_user.cancel_new_phone_number
    redirect_to activity_path
  end
end
