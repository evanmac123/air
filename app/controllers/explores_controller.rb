class ExploresController < ClientAdminBaseController
  include TileBatchHelper

  def show
    @tiles = Tile.viewable_in_public.order("created_at DESC").limit(tile_batch_size)

    if params[:partial_only]
      render partial: "shared/tile_wall", locals: {tiles: @tiles, path_for_more_tiles: explore_path}
    end
  end
end
