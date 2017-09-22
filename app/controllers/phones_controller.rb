class PhonesController < UserBaseController
  def update
    user_phone_updater = User::PhoneUpdaterService.new(user: current_user, phone_number: params[:user][:phone_number]).dispatch

    flash[user_phone_updater.flash_type] = user_phone_updater.flash_msg

    redirect_to :back
  end

  def validate
    if current_user.validate_new_phone(params[:user][:new_phone_validation])
      current_user.confirm_new_phone_number
      if current_user.save
        add_success "You have updated your phone number."
        redirect_to :back and return
      end
    end

    add_failure wrong_phone_validation_code_error
    redirect_to :back
  end

  private

    def wrong_phone_validation_code_error
      "Sorry, the code you entered was invalid. Please try typing it again."
    end
end
