class ExploresController < ClientAdminBaseController
  include TileBatchHelper

  before_filter :find_tiles

  def show
    @tile_tags = TileTag.alphabetical.with_public_non_draft_tiles
    @all_tiles_displayed = @tiles.count <= tile_batch_size
    @tiles = @tiles.limit(tile_batch_size)
    @path_for_more_tiles = explore_path

    render_partial_if_requested(tag_click_source: 'Explore Main Page - Clicked Tag On Tile', thumb_click_source: 'Explore Main Page - Tile Thumbnail Clicked')

    if params[:return_to_explore_source]
      ping_action_after_dash params[:return_to_explore_source], {}, current_user
    end
  end
  
  def tile_tag_show
    batch_size = tile_batch_size
    batch_size = 16 if batch_size < 16

    @tile_tag = TileTag.find(params[:tile_tag])
    @all_tiles_displayed = @tiles.count <= batch_size
    @tiles = @tiles.limit(batch_size)
    @path_for_more_tiles = tile_tag_show_explore_path(tile_tag: params[:tile_tag])
    
    render_partial_if_requested(tag_click_source: "Explore Topic Page - Clicked Tag On Tile", thumb_click_source: 'Explore Topic Page - Tile Thumbnail Clicked')

    if params[:tag_click_source].present?
      ping_action_after_dash(params[:tag_click_source], {tag: @tile_tag.title}, current_user)
    end
  end

  protected

  def find_tiles
    @tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag]).order("created_at DESC").includes(:creator)
  end

  def render_partial_if_requested(extra_locals)
    if params[:partial_only]
      ping("Explore Topic Page", {action: "Clicked See More"}, current_user)
      render partial: "explores/tile_with_tags", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles, all_tiles_displayed: @all_tiles_displayed, show_back_to_explore_link_in_post_copy_modal: false}.merge(extra_locals)
    end
  end
end
