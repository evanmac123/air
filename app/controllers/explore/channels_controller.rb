class Explore::ChannelsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    @channel = Channel.find_by_slug(params[:id])
    @tiles = @channel.tiles.page(params[:page]).per(40)

    respond_to do |format|
      format.html {
        @display_channels = Channel.display_channels(@channel.slug)
      }

      format.json {
      }
    end
  end
end
