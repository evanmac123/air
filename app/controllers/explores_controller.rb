class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  
  def show
    @tile_tags = TileTag.alphabetical.with_public_active_tiles
    @tiles = Tile.viewable_in_public.order("created_at DESC").limit(tile_batch_size).includes(:creator)
    if params[:partial_only]
      render partial: "shared/tile_wall", locals: {not_completed_tiles: @tiles, path_for_more_tiles: explore_path(tag_id: params[:tag_id]), display_creator_info: true, selected_tag_id: params[:tag_id]}
    end
  end
  
  def tile_tag_show
    @tile_tag = TileTag.find(params[:tile_tag])
    @tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag]).
      order("created_at DESC").includes(:creator)#.limit(tile_batch_size)
  end
  
  def tile_preview
    @tile = Tile.find(params[:tile])
  end
    
end
