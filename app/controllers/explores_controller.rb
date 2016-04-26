class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  before_filter :find_tiles
  before_filter :set_all_tiles_displayed
  before_filter :limit_tiles_to_batch_size

  def show
    @topics = Topic.rearrange_by_other
    @path_for_more_tiles = explore_path
    @parent_boards = Demo.where(is_parent: true)

    render_partial_if_requested

    @show_explore_intro = current_user.intros.show_explore_intro!

    if params[:return_to_explore_source]
      ping_action_after_dash params[:return_to_explore_source], {}, current_user
    end

    email_clicked_ping(current_user)
    explore_intro_ping @show_explore_intro, params
    explore_content_link_ping
  end

  def tile_tag_show
    @tiles = @tiles.reorder("position desc")

    @tile_tag = TileTag.find(params[:tile_tag])
    @path_for_more_tiles = tile_tag_show_explore_path(tile_tag: params[:tile_tag])

    render_partial_if_requested

    if params[:tag_click_source].present?
      ping_action_after_dash(params[:tag_click_source], {tag: @tile_tag.title}, current_user)
    end
    ping("Viewed Collection", {tag: @tile_tag.title}, current_user)
  end

  add_method_tracer :show
  add_method_tracer :tile_tag_show

  protected
     def find_tile_tags
      params[:tile_tag]
    end
end
