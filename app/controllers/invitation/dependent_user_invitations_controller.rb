class Invitation::DependentUserInvitationsController < ApplicationController
  def new
    render partial: 'dependent_email_form'
  end

  def create
    dependent_user = PotentialUser.where(email: permit_params[:email], primary_user_id: current_user.id, demo_id: current_user.demo.dependent_board_id).first_or_create
    if dependent_user.valid?
      dependent_user.invite_as_dependent(permit_params[:subject], permit_params[:body])

      head :ok
      render 'success'
    else
      head :unprocessable_entity
    end
  end

  protected
    def permit_params
      params.require(:dependent_user_invitation).permit(:email, :subject, :body)
    end
end
