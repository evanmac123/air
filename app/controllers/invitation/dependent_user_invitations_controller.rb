class Invitation::DependentUserInvitationsController < ApplicationController
  def create
    dependent_user = PotentialUser.where(email: permit_params[:email], game_referrer: current_user, demo_id: current_user.demo.dependent_board_id).first_or_create
    if dependent_user
      dependent_user.invite_as_dependent(permit_params[:subject], permit_params[:body])

      head :ok
    else
      head :unprocessable_entity and return
    end
  end

  protected
    def permit_params
      params.require(:dependent_user_invitation).permit(:email, :subject, :body)
    end
end
