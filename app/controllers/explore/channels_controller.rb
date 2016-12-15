class Explore::ChannelsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @channel = Channel.find_by_slug(params[:id])
    @display_channels = Channel.display_channels(@channel.slug)
  end
end
