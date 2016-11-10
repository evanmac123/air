class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    find_tiles_and_collections
    @path_for_more_content = explore_path

    render_partial_if_requested
  end

  def tile_tag_show
    find_tiles
    @tiles = @tiles.reorder("position desc")

    @tile_tag = TileTag.find(params[:tile_tag])
    @path_for_more_content = tile_tag_show_explore_path(tile_tag: params[:tile_tag])

    render_partial_if_requested

    if params[:tag_click_source].present?
      ping_action_after_dash(params[:tag_click_source], {tag: @tile_tag.title}, current_user)
    end

    ping("Viewed Collection", {tag: @tile_tag.title}, current_user)
  end

  add_method_tracer :show
  add_method_tracer :tile_tag_show
end
