class Invitation::DependentUserInvitationsController < UserBaseController
  def new
    render partial: 'dependent_email_form'
  end

  def create
    dependent_user = get_dependent_user

    if dependent_user.valid?
      dependent_user.invite_as_dependent(permit_params[:subject], permit_params[:body])

      render partial: 'success'
    else
      head :unprocessable_entity
    end
  end

  private
  
    def permit_params
      params.require(:dependent_user_invitation).permit(:email, :subject, :body)
    end

    def get_dependent_user
      PotentialUser.where(
        email: permit_params[:email],
        primary_user_id: current_user.id,
        demo_id: current_user.demo.dependent_board_id
      ).first_or_create
    end
end
