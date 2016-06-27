class ChangeEmailsController < ApplicationController
  skip_before_filter :authorize

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
    change_log = UserSettingsChangeLog.where(email_token: params[:token]).first

    if change_log && change_log.update_user_email
      sign_in(change_log.reload.user, 1)
      flash[:success] = "Your email was successfully changed to #{current_user.email}"
    else
      flash[:failure] = "Error. Email was not changed. Plese, go to settings and try to change it again."
    end
    redirect_to '/'
  end

  protected
    def permit_params
      params.require(:change_email).permit(:email)
    end
end
