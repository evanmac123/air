class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  
  def show
    @tile_tags = TileTag.alphabetical.with_public_active_tiles
    @tiles = Tile.viewable_in_public.order("created_at DESC").limit(tile_batch_size).includes(:creator)
    @path_for_more_tiles = explore_path
    if params[:partial_only]
      render partial: "explores/tile_with_tags", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles}
    end
  end
  
  def tile_tag_show
    @tile_tag = TileTag.find(params[:tile_tag])
    @tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag]).
      order("created_at DESC").includes(:creator).limit(tile_batch_size)
    @path_for_more_tiles = tile_tag_show_explore_path(tile_tag: params[:tile_tag])
    
    if params[:partial_only]
      render partial: "explores/tile_with_tags", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles}
    end
  end
  
  def tile_preview
    @tile = Tile.find(params[:tile])
  end    
end
