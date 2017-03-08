class Invitation::DependentUserInvitationsController < UserBaseController
  def new
    render partial: 'dependent_email_form'
  end

  def create
    dependent_user = get_dependent_user

    if dependent_user && dependent_user.valid?
      dependent_user.invite_as_dependent(permit_params[:subject], permit_params[:body])

      render partial: 'success'
    else
      render partial: 'failure'
    end
  end

  private

    def permit_params
      params.require(:dependent_user_invitation).permit(:email, :subject, :body)
    end

    def get_dependent_user
      return false if invitee_already_in_board

      PotentialUser.where(
        email: permit_params[:email],
        primary_user_id: current_user.id,
        demo_id: current_user.demo.dependent_board_id
      ).first_or_create
    end

    def invitee_already_in_board
      current_user.demo.users.where(email: permit_params[:email]).present?
    end
end
