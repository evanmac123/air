class ClientAdmin::ChannelsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @channel = Channel.find(params[:id])
    @display_channels = Channel.display_channels(@channel.id)
  end
end
