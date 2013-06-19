class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    user_ids = @demo.users.pluck(:id)
    tile_ids = @demo.digest_tiles.pluck(:id)

    TilesDigestMailer.delay.notify_all(user_ids, tile_ids)

    # todo only do this if from 'Send Now' button; don't do from DelayedJob
    # todo but the job that is run needs to update the 'sent_at' time => spec for this
    # todo also need to ensure (and spec) that no email is sent if no tiles
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
