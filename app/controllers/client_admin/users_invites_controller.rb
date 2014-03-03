class ClientAdmin::UsersInvitesController < ClientAdminBaseController
  include EmailHelper
  def create
    params[:users_invite][:demo_id] = current_user.demo_id
    
    users_invite = UsersInvite.new(params[:users_invite])
    respond_to do |format|
      users_invite.send_invites(current_user)
      if users_invite.errors.empty?
        format.html { redirect_to :back, notice: 'Invitations were sent successfully' }
        format.json { render nothing: true, status: :created }
      else
        format.all { render json: {errors: users_invite.errors}, status: :unprocessible_entity }
      end
    end
  end
  
  def preview_invite_email
    
    @demo  = current_user.demo
    @user  = User.new(name: 'Invited User')
    @tiles = @demo.digest_tiles.order('activated_at DESC')
    @follow_up_email = false
    @custom_message = 'Check out my new board!'

    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)    

    render partial: 'shared/notify_one'
  end
end
