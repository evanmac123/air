class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  
  def show
    @tile_tags = TileTag.alphabetical.with_public_active_tiles
    @tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag])
    @all_tiles_displayed = @tiles.count <= tile_batch_size
    @tiles = @tiles.order("created_at DESC").limit(tile_batch_size).includes(:creator)
    @path_for_more_tiles = explore_path
    if params[:partial_only]
      render partial: "explores/tile_with_tags", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles, all_tiles_displayed: @all_tiles_displayed, source: 'Explore Main Page - Clicked Tag On Tile'}
    end
  end
  
  def tile_tag_show
    @tile_tag = TileTag.find(params[:tile_tag])
    @tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag])
    batch_size = tile_batch_size
    batch_size = 16 if batch_size < 16
    @all_tiles_displayed = @tiles.count <= batch_size
    @tiles = @tiles.order("created_at DESC").includes(:creator).limit(batch_size)
    
    @path_for_more_tiles = tile_tag_show_explore_path(tile_tag: params[:tile_tag])
    
    if params[:partial_only]
      render partial: "explores/tile_with_tags", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles, all_tiles_displayed: @all_tiles_displayed, source: "Topic Page - Clicked Tag On Tile"}
    end

    if params[:source].present?
      TrackEvent.ping(params[:source], {tag: @tile_tag.title}, current_user)
    end
  end
  
end
