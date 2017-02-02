class Explore::ChannelsController < ExploreBaseController
  include ExploreConcern

  def show
    @channel = Channel.find_by_slug(params[:id]) || virtual_channel
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
      track_user_channels(@channel.name)
      @related_features = @channel.related_features
      @related_campaigns = @channel.related_campaigns
      @display_channels = Channel.display_channels(@channel.slug)
    end
  end

  private

    def virtual_channel
      name = params[:id].split("-").join(" ").humanize
      Channel.new(name: name, slug: name.parameterize)
    end
end
