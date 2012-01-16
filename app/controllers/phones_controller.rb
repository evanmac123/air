class PhonesController < ApplicationController
  def update
    if params[:user][:new_phone_validation] == current_user.new_phone_validation
      current_user.confirm_new_phone_number
      if current_user.save
        add_success "You have updated your phone number."
        redirect_to :back and return
      end
    end

    add_failure "Sorry, the code you entered was invalid. Please try typing it again."
    redirect_to :back
  end
end
