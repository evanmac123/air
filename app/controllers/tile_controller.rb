class TileController < ApplicationController
  skip_before_filter :authorize
  prepend_before_filter :find_tile
  before_filter :allow_guest_user
  
  def show
    set_guest_user_if_needed
    authorize

    @public_tile_page = true
    tile_viewed_ping
  end

  protected

  def set_guest_user_if_needed
    unless current_user || session[:guest_user].present?
      session[:guest_user] = {demo_id: @tile.demo_id} 
    end
  end

  def find_current_board
    @tile.demo
  end

  def find_tile
    @tile = Tile.where(id: params[:id], is_sharable: true).first
    unless @tile
      not_found 
      return
    end
  end

  def tile_viewed_ping
    ping('Tile - Viewed', {tile_type: "Public Tile", tile_id: @tile.id}, current_user)
  end

  def override_public_board_setting
    @tile && @tile.is_sharable
  end
end
