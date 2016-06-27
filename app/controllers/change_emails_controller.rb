class ChangeEmailsController < ApplicationController
  skip_before_filter :authorize

  def new
    render partial: 'form'
  end

  def create
    change_log = UserSettingsChangeLog.where(user: current_user).first_or_create
    if current_user.email != permit_params[:email] &&
       permit_params[:email].present? &&
       change_log.save_email(permit_params[:email])

      change_log.send_confirmation_for_email

      respond_to do |format|
        format.js { render partial: 'success' }
        format.html do
          flash[:success] = "Confirmation email was sent to your current address. Please, confirm your change!"
          redirect_to :back
        end
      end
    else
      respond_to do |format|
        format.js do
          head :unprocessable_entity
          # render nothing: true
        end
        format.html do
          flash[:failure] = "That's not a valid email!"
          redirect_to :back
        end
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
