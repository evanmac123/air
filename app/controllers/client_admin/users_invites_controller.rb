class ClientAdmin::UsersInvitesController < ClientAdminBaseController
  def create
    params[:users_invite][:demo_id] = current_user.demo_id
    
    users_invite = UsersInvite.new(params[:users_invite])
    respond_to do |format|
      users_invite.send_invites
      if users_invite.errors.empty?
        format.html { redirect_to :back, notice: 'Invitations were sent successfully' }
        format.json { render nothing: true, status: :created }
      else
        format.all { render json: {errors: users_invite.errors}, status: :unprocessable_entity }
      end
    end
  end
end
