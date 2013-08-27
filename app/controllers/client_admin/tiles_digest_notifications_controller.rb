class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    # Grab all of the tiles now because we're gonna be resetting the 'tile_digest_email_sent_at' real soon...
    tile_ids = @demo.digest_tiles.pluck(:id)

    TilesDigestMailer.delay.notify_all(@demo.id, tile_ids)

    @demo.update_attributes tile_digest_email_sent_at: Time.now

    flash[:success] = "Tiles digest email was sent"
    redirect_to client_admin_tiles_path
  end

  def update
    if params[:send_on]
      update_send_on
    else
      update_send_to
    end
  end

  private

  def get_demo
    @demo = current_user.demo
  end

  def update_send_on
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]
    render text: "Send-on day updated to #{@demo.tile_digest_email_send_on}"
  end

  def update_send_to
    @demo.update_attributes(unclaimed_users_also_get_digest: params[:send_to])

    feedback = if params[:send_to] == 'true'
      "All users will get digest emails"
    else
      "Only joined users will get digest emails"
    end

    render text: feedback
  end
end
