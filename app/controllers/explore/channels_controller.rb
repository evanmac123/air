class Explore::ChannelsController < ExploreBaseController
  def show
    @channel = Channel.find_by_slug(params[:id])
    @tiles = @channel.tiles.page(params[:page]).per(28)

    if request.xhr?
      content = render_to_string(
                  partial: "explore/tiles",
                  locals: { tiles: @tiles, section: "Channel" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
      }
    else
      @related_features = @channel.related_features
      @related_campaigns = @channel.related_campaigns
      @display_channels = Channel.display_channels(@channel.slug)
    end
  end
end
