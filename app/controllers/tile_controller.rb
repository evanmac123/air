class TileController < ApplicationController
  prepend_before_filter :find_tile
  prepend_before_filter :allow_guest_user
  
  def show
    @public_tile_page = true
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
end
