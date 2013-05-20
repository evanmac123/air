class ClientAdmin::TileDigestNotificationsController < ClientAdminBaseController
  before_filter :get_demo

  private

  def get_demo
    @demo = current_user.demo
  end
end
