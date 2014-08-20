class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_tile # must run before authorize_as_guest, so that we can use the tile to implement #find_current_board
  before_filter :authorize_by_explore_token

  before_filter :allow_guest_user
  before_filter :login_as_guest_to_tile_board
  before_filter :authorize_as_guest

  layout "client_admin_layout"

  include LoginByExploreToken

  def show
    if params[:partial_only]
      show_partial
    else
      @tile = Tile.viewable_in_public.where(id: params[:id]).first
      @tag = TileTag.where(id: params[:tag]).first

      schedule_mixpanel_pings @tile
    end
  end

  protected

  def show_partial
    tag = TileTag.where(id: params[:tag]).first
    next_tile = Tile.next_public_tile params[:id], params[:offset].to_i, params[:tag]

    render json: {
      tile_content: render_to_string(partial: "tile_previews/tile_preview", locals: { tile: next_tile, tag: tag })
    }
    ping_on_arrow params[:offset].to_i
    return
  end

  def ping_on_arrow offset
    action = offset > 0 ? "Clicked arrow to next tile" : "Clicked arrow to previous tile"
    ping "Explore page - Interaction", {action: action}, current_user
  end

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user

    if params[:thumb_click_source]
      ping_action_after_dash params[:thumb_click_source], {tile_id: tile.id}, current_user
    end
  end

  def find_tile
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
  end

  def find_current_board
    @tile.demo
  end

  def login_as_guest_to_tile_board
    if current_user.nil?
      login_as_guest(@tile.demo)
    end
  end
end
