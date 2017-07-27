class TileController < ApplicationController
  include AllowGuestUsersConcern

  prepend_before_filter :find_tile

  def show
    @public_tile_page = true
    @explore_or_public = :public
    tile_viewed_ping

    render "explore/tile_previews/single_explore_tile", layout: "single_tile_base_layout"
  end

  private

    def find_board_for_guest
      @demo ||= @tile.demo
    end

    def find_tile
      @tile = Tile.where(id: params[:id], is_sharable: true).first
      unless @tile
        not_found('flashes.failure_tile_not_public')
        return
      end
    end

    def tile_viewed_ping
      ping('Tile - Viewed', {tile_type: "Public Tile", tile_id: @tile.id}, current_user)
    end
end
