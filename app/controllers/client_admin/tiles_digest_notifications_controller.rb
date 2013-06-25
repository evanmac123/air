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
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]
    render text: "Send-on day updated to #{@demo.tile_digest_email_send_on}"
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
