class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    #TilesDigestMailer.delay.notify(@demo.id)

    flash[:success] = "Tiles digest email was sent"
    redirect_to client_admin_tiles_path

    #@demo.update_attributes tile_digest_email_sent_at: Time.now
    #@tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
  end

  def update
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]
    flash[:success] = "Digest email weekly-send-on day was updated to #{@demo.tile_digest_email_send_on}"
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
