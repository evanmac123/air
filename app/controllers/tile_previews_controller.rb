class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout "client_admin_layout"

  def show
    if params[:partial_only]
      show_partial
    else
      @tile = Tile.viewable_in_public.where(id: params[:id]).first
      @tag = TileTag.where(id: params[:tag]).first

      session[:guest_user] ||= {demo_id: @tile.demo.id}
      schedule_mixpanel_pings @tile
    end
  end

  protected

  def show_partial
    next_tile = Tile.next_public_tile params[:id], params[:offset].to_i

    render json: {
      tile_content: render_to_string(partial: "tile_previews/tile_preview", locals: { tile: next_tile, tag: nil })
    }
    return
  end

  def find_next_tile
    tiles = Tile.viewable_in_public
    tile = Tile.viewable_in_public.where(id: params[:id]).first
    next_tile = if tiles.count > 1 
                  if params[:offset].to_i > 0
                    tiles[tiles.index(tile) + params[:offset].to_i] || tiles.first
                  else
                    tiles[tiles.index(tile) + params[:offset].to_i] || tiles.last
                  end
                else
                  tile
                end
  end

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user

    if params[:thumb_click_source]
      ping_action_after_dash params[:thumb_click_source], {tile_id: tile.id}, current_user
    end
  end
end
