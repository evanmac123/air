class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    @demo.update_attributes tile_digest_email_sent_at: Time.now
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
  end

  def show
    @message = TilesDigestMailer.notify
    render layout: false
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
