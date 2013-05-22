class ClientAdmin::TileDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  def show
    render layout: false
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
