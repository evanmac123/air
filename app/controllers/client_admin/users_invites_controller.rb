class ClientAdmin::UsersInvitesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper

  def create
    params[:users_invite][:demo_id] = current_user.demo_id

    users_invite = UsersInvite.new(params[:users_invite])
    respond_to do |format|
      users_invite.send_invites(current_user)
      if users_invite.errors.empty?
        current_user.demo.update_attributes tile_digest_email_sent_at: Time.now
        format.html { redirect_to :back, notice: 'Invitations sent successfully' }
        format.json { render nothing: true, status: :created }
      else
        format.all { render json: {errors: users_invite.errors}, status: :unprocessible_entity }
      end
    end
  end
  
  def preview_invite_email    
    @demo  = current_user.demo
    @user  = current_user#User.new(name: 'Invited User')
    @follow_up_email = false
    @onboarding_email = true
    @custom_message = params[:custom_message]||'Check out my new board!'
    if params[:is_invite_user] == 'true'
      @title = "Join my #{@demo.name}"      
      @email_heading = "Join my #{@demo.name}"
      @tiles = @demo.digest_tiles(nil).order('activated_at DESC')
    else
      @title = @email_heading = digest_email_heading
      @tiles = @demo.digest_tiles.order('activated_at DESC')      
    end
    @invitation_url = @user.claimed? ? nil : invitation_url(@user.invitation_code, protocol: email_link_protocol, host: email_link_host)    
    @is_preview = true
    render 'tiles_digest_mailer/notify_one', :layout => false
  end
end
