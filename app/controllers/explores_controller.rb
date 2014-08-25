class ExploresController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken

  before_filter :find_tiles

  def show
    @tile_tags = TileTag.alphabetical.with_public_non_draft_tiles
    @batch_size = tile_batch_size
    @all_tiles_displayed = @tiles.count <= @batch_size
    @tiles = @tiles.limit(tile_batch_size)
    @path_for_more_tiles = explore_path

    render_partial_if_requested(tag_click_source: 'Explore Main Page - Clicked Tag On Tile', thumb_click_source: 'Explore Main Page - Tile Thumbnail Clicked')

    if params[:return_to_explore_source]
      ping_action_after_dash params[:return_to_explore_source], {}, current_user
    end

    email_clicked_ping(current_user)
  end
  
  def tile_tag_show
    @batch_size = tile_batch_size
    @batch_size = 16 if @batch_size < 16 && first_tile_batch

    @tile_tag = TileTag.find(params[:tile_tag])
    @all_tiles_displayed = @tiles.count <= @batch_size
    @tiles = @tiles.limit(@batch_size)
    @path_for_more_tiles = tile_tag_show_explore_path(tile_tag: params[:tile_tag])
    
    render_partial_if_requested(tag_click_source: "Explore Topic Page - Clicked Tag On Tile", thumb_click_source: 'Explore Topic Page - Tile Thumbnail Clicked')

    if params[:tag_click_source].present?
      ping_action_after_dash(params[:tag_click_source], {tag: @tile_tag.title}, current_user)
    end
  end

  protected

  def find_tiles
    @eligible_tiles = Tile.viewable_in_public.tagged_with(params[:tile_tag])

    @tiles = @eligible_tiles.
      order("created_at DESC").
      offset(offset).
      includes(:creator).
      includes(:tile_tags).
      includes(:user_tile_likes).
      includes(:user_tile_copies)

    @liked_tile_ids = UserTileLike.where(user_id: current_user.id, tile_id: @tiles.map(&:id)).pluck(:tile_id)
  end

  def render_partial_if_requested(extra_locals)
    if params[:partial_only]
      ping("Explore Topic Page", {action: "Clicked See More"}, current_user)

      html_content = render_to_string partial: "explores/tile_rows", locals: {tiles: @tiles, path_for_more_tiles: @path_for_more_tiles, show_back_to_explore_link_in_post_copy_modal: false}.merge(extra_locals)
      last_batch = @eligible_tiles.count <= offset + @batch_size

      render json: {
        htmlContent: html_content,
        lastBatch:   last_batch
      }
    end
  end

  def offset
    @_offset = params[:offset].present? ? params[:offset].to_i : 0
  end
end
