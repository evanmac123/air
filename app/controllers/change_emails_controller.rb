class ChangeEmailsController < ApplicationController
  def new
    render partial: 'change_email_form'
  end

  def create
    if permit_params[:email].present?

      # head :ok
      render partial: 'success'
    else
      head :unprocessable_entity
    end
  end

  protected
    def permit_params
      params.require(:change_email).permit(:email)
    end
end
