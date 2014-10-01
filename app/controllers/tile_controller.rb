class TileController < ApplicationController
  prepend_before_filter :find_tile
  prepend_before_filter :allow_guest_user

  #layout "client_admin_layout"

  def show
    @public_tile_page = true
  end

  protected

  def find_current_board
    @tile.demo
  end

  def find_tile
    @tile = Tile.find(params[:id])
  end
end
