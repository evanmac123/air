class TileController < ApplicationController
  prepend_before_filter :login_as_guest
  prepend_before_filter :find_tile

  def show
    @public_tile_page = true
    tile_viewed_ping
  end

  private

    def find_current_board
      @current_board ||= @tile.demo
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
end
