class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def create
    TilesDigestMailer.notify(@demo).deliver

    @demo.update_attributes tile_digest_email_sent_at: Time.now
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
  end

  def update
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]
    render text: "Send-on day updated to #{@demo.tile_digest_email_send_on}"
  end

  private

  def attachment_url_1(file)
    "#{request.protocol}#{request.host_with_port}#{file.url}"
  end

  def attachment_url_2(file)
    URI.join(request.url, file.url)
  end

  def get_demo
    @demo = current_user.demo
  end
end
