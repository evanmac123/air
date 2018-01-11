class Explore::TileFeaturesController < ExploreBaseController
  def show
    @tile_feature = TileFeature.find_by(slug: params[:id])
    @related_tiles = @tile_feature.related_tiles.page(params[:page]).per(28)

    if request.xhr?
      content = render_to_string(
                  partial: "explore/tiles",
                  locals: { tiles: @related_tiles, section: "Tile Feature" })

      render json: {
        success:   true,
        content:   content,
        added:     @related_tiles.count,
        lastBatch: params[:count] == @related_tiles.total_count.to_s
      }
    else
      @related_campaigns = @tile_feature.related_campaigns
      @display_channels = Channel.display_channels(@tile_feature.slug)
    end
  end
end
