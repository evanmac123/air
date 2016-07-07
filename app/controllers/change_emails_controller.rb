class ChangeEmailsController < ApplicationController
  skip_before_filter :authorize

  def new
    render partial: 'form'
  end

  def create
    change_log = UserSettingsChangeLog.where(user: current_user).first_or_create
    new_email = permit_params[:email]
    if change_log.save_email(new_email)
      change_log.send_confirmation_for_email
      if request.xhr?
        render partial: 'success'
      else
        flash[:success] = "A confirmation email was sent to your current email address. Please click the button in the email to confirm your email change."
        redirect_to :back
      end
    else
      failure_mess = "Email #{change_log.errors.messages[:email].join(', ')}"
      if request.xhr?
        render text: failure_mess, status: :unprocessable_entity
      else
        flash[:failure] = failure_mess
        redirect_to :back
      end
    end
  end

  def show
    change_log = UserSettingsChangeLog.where(email_token: params[:token]).first
    if change_log && change_log.update_user_email
      user = change_log.reload.user
      sign_in(user, 1)
      ping('Changed Email', {}, user)
      flash[:success] = "Your email was successfully changed to #{current_user.email}"
      redirect_to activity_path
    else
      flash[:failure] = "Error. Email was not changed. Plese, go to settings and try to change it again."
      redirect_to '/'
    end
  end

  protected
    def permit_params
      params.require(:change_email).permit(:email)
    end
end
