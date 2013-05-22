class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def show
    render layout: false
  end

  def update
    @demo.update_attributes tile_digest_email_send_on: params[:send_on]

    render text: "************ New Day Is: #{params[:send_on]}"
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
