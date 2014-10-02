class TileController < ApplicationController
  skip_before_filter :authorize
  prepend_before_filter :find_tile
  before_filter :allow_guest_user
  
  def show
    session[:guest_user] = {demo_id: find_current_board.id}
    authorize

    @public_tile_page = true
    tile_viewed_ping
  end

  protected

  def find_current_board
    @tile.demo
  end

  def find_tile
    @tile = Tile.where(id: params[:id]).first
    unless @tile
      not_found 
      return
    end
  end

  def tile_viewed_ping
    ping('Tile Viewed', {tile_type: "Public Tile"}, current_user)
  end
end
