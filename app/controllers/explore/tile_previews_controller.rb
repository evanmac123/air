class Explore::TilePreviewsController < ExploreBaseController
  include ExploreConcern

  prepend_before_filter :find_tile

  def show
    schedule_mixpanel_pings(@tile)

    if request.xhr?
      @next_tile = params[:next_tile] || @tile.id
      @prev_tile = params[:prev_tile] || @tile.id
      render partial: "explore/tile_previews/tile_preview",
             locals: { tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile, section: params[:section] },
             layout: false
    else
      # TODO: merge layouts for an explore that is open to all
      render "show", layout: "single_tile_guest_layout" if  current_user.is_a?(GuestUser)
    end
  end

  private

    def schedule_mixpanel_pings(tile)
      if params[:from_search]
        ping("Tile - Viewed in Search", { tile_id: tile.id, tile_type: "Explore" }, current_user)
      else
        ping("Tile - Viewed in Explore", {tile_id: tile.id, section: params[:section]}, current_user)
      end

      email_clicked_ping(current_user) if current_user
    end

    def find_board_for_guest
      @demo ||= @tile.demo
    end

    def find_tile
      begin
        @tile ||= Tile.explore.find(params[:id])
      rescue
        not_found
      end
    end
end
