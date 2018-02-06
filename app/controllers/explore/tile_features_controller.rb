# frozen_string_literal: true

class Explore::TileFeaturesController < ExploreBaseController
  def show
    @tile_feature = TileFeature.find_by(slug: params[:id])
    @tiles = @tile_feature.related_tiles(page: params[:page], per: 28)

    if request.xhr?
      content = render_to_string(
        partial: "explore/tiles",
        locals: { tiles: @tiles, section: "Tile Feature" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
      }
    else
      @related_campaigns = @tile_feature.related_campaigns
    end
  end
end
