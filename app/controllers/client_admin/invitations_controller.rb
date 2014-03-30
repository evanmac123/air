class ClientAdmin::InvitationsController < ClientAdminBaseController
  def create
    user = current_user.demo.users.find_by_slug(params[:user_id])
    user.invitation_method = "client_admin"
    user.invite(nil, demo_id: current_user.demo.id)

    respond_to do |format|
      format.html do
        flash[:success] = "OK, we've just sent #{user.name} an invitation."
        redirect_to :back
      end

      format.js do
        render :nothing => true
      end
    end
  end
end
