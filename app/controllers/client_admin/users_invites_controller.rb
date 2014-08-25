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
    @user  = current_user # XTR

    custom_message = params[:custom_message] || 'Check out my new board!'
    is_invite_user = params[:is_invite_user] == 'true'

    @presenter = TilesDigestMailPreviewPresenter.new(custom_message, @demo, is_invite_user)

    if is_invite_user
      tiles = @demo.digest_tiles(nil).order('activated_at DESC')
    else
      tiles = @demo.digest_tiles.order('activated_at DESC')      
    end
    @tiles = TileBoardDigestDecorator.decorate_collection tiles, \
                                                          context: {
                                                            demo: @demo,
                                                            user: @user,
                                                            follow_up_email: @follow_up_email,
                                                            is_preview: @presenter.is_preview
                                                          }

    @general_site_link = email_site_link(@user, @demo, @presenter.is_preview)

    render 'tiles_digest_mailer/notify_one', :layout => false
  end
end
