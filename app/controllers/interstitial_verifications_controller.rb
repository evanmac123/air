class InterstitialVerificationsController < ApplicationController
  skip_before_filter :authenticate
  before_filter :authenticate_without_game_begun_check

  def show
  end

  def update
    if current_user.validate_new_phone(params[:user][:new_phone_validation])
      current_user.confirm_new_phone_number
      current_user.save!
      SMS.send_message(current_user, current_user.demo.welcome_message(current_user))
      current_user.schedule_followup_welcome_message
      redirect_to activity_path
    else
      add_failure wrong_phone_validation_code_error
      redirect_to :back
    end
  end
end
