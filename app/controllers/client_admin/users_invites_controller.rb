# frozen_string_literal: true

class ClientAdmin::UsersInvitesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper

  skip_after_action :intercom_rails_auto_include, only: [:preview_tiles_digest_email]

  def create
    params[:users_invite][:demo_id] = current_user.demo_id

    users_invite = UsersInvite.new(params[:users_invite])
    respond_to do |format|
      users_invite.send_invites(current_user)
      if users_invite.errors.empty?
        current_user.demo.update_attributes tile_digest_email_sent_at: Time.current
        format.html { redirect_to :back, notice: "Invitations sent successfully" }
        format.json { render nothing: true, status: :created }
      else
        format.all { render json: { errors: users_invite.errors }, status: :unprocessible_entity }
      end
    end
  end

  def preview_tiles_digest_email
    # TODO: Move this somewhere that makes sense! (this is the Tile Email preview shown on the share tab).
    @user  = current_user
    @demo  = current_board

    @follow_up_email = params[:follow_up_email] == "true"
    presenter_class = @follow_up_email ? FollowUpDigestPreviewPresenter : TilesDigestPreviewPresenter
    @presenter = presenter_class.new(@user, @demo)

    @tiles = @presenter.tiles

    render "tiles_digest_mailer/notify_one", layout: false
  end
end
