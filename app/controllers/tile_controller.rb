class TileController < ApplicationController
  prepend_before_filter :find_tile
  prepend_before_filter :allow_guest_user
  
  def show
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
