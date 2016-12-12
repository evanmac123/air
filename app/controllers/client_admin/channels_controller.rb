class ClientAdmin::ChannelsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @channel = Channel.find(params[:id])
  end
end
