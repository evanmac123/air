class ClientAdmin::UsersInvitesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper


  prepend_before_action :allow_same_origin_framing, only: [:preview_tiles_digest_email]
  skip_after_action :intercom_rails_auto_include, only: [:preview_tiles_digest_email]

  def create
    params[:users_invite][:demo_id] = current_user.demo_id

    users_invite = UsersInvite.new(params[:users_invite])
    respond_to do |format|
      users_invite.send_invites(current_user)
      if users_invite.errors.empty?
        current_user.demo.update_attributes tile_digest_email_sent_at: Time.current
        format.html { redirect_to :back, notice: 'Invitations sent successfully' }
        format.json { render nothing: true, status: :created }
      else
        format.all { render json: {errors: users_invite.errors}, status: :unprocessible_entity }
      end
    end
  end

  def preview_tiles_digest_email
    @demo  = current_user.demo
    @user  = current_user # XTR

    is_invite_user = params[:is_invite_user] == 'true'
    if is_invite_user
      tiles = @demo.digest_tiles(nil).ordered_by_position
    else
      tiles = @demo.digest_tiles.ordered_by_position
    end

    has_no_tiles = tiles.empty?
    custom_message = params[:custom_message] || 'Check out my new board!'

    @follow_up_email = params[:follow_up_email] == "true"
    presenter_class = @follow_up_email ? TilesDigestMailPreviewFollowUpPresenter : TilesDigestMailPreviewDigestPresenter
    @presenter = presenter_class.new(@user, @demo, custom_message, is_invite_user, has_no_tiles)

    @tiles = unless @presenter.is_empty_preview?
      TileBoardDigestDecorator.decorate_collection tiles, \
                                                          context: {
                                                            demo: @demo,
                                                            user: @user,
                                                            follow_up_email: @follow_up_email,
                                                            is_preview: @presenter.is_preview
                                                          }
    else
      [nil, nil] # to show tile placeholders
    end

    render 'tiles_digest_mailer/notify_one', :layout => false
  end
end
