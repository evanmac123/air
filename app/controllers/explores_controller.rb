class ExploresController < ClientAdminBaseController
  include TileBatchHelper

  def show
    @tiles = Tile.viewable_in_public.tagged_with(params[:tag_id]).order("created_at DESC").limit(tile_batch_size).includes(:creator)
    @tags = TileTag.alphabetical.with_public_tiles

    if params[:partial_only]
      render partial: "shared/tile_wall", locals: {not_completed_tiles: @tiles, path_for_more_tiles: explore_path(tag_id: params[:tag_id]), display_creator_info: true}
    end
  end
end
