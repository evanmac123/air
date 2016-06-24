class ChangeEmailsController < ApplicationController
  def new
    render partial: 'change_email_form'
  end

  def create
    change_log = UserSettingsChangeLog.where(user: current_user).first_or_create
    if change_log.save_email permit_params[:email]
      change_log.send_confirmation_for_email
      render partial: 'success'
    else
      head :unprocessable_entity
    end
  end

  def show

  end

  protected
    def permit_params
      params.require(:change_email).permit(:email)
    end
end
