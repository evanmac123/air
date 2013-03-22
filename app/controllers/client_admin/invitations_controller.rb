class ClientAdmin::InvitationsController < ClientAdminBaseController
  def create
    user = current_user.demo.users.find_by_slug(params[:user_id])
    user.invite
    flash[:success] = "OK, we've just sent #{user.name} an invitation."
    redirect_to :back
  end
end
