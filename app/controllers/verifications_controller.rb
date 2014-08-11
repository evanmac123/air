class VerificationsController < ApplicationController
  skip_before_filter :authorize
  before_filter :authorize_without_game_begun_check

  def show
    current_user.ping_page("interstitial phone verification")
  end

  def update
    if current_user.validate_new_phone(params[:user][:new_phone_validation])
      current_user.confirm_new_phone_number
      current_user.save!
      add_success "Your phone number has been validated"
      redirect_to activity_path
    else
      add_failure wrong_phone_validation_code_error
      redirect_to :back
    end
  end
end
