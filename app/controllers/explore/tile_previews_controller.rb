class Explore::TilePreviewsController < ExploreBaseController
  include ExploreConcern

  prepend_before_filter :find_tile

  def show
    # TODO: Refactor out single tile view to separate action
    schedule_mixpanel_pings(@tile)

    if request.xhr?
      @next_tile = params[:next_tile] || @tile
      @prev_tile = params[:prev_tile] || @tile

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
      ping("Tile - Viewed in Explore", {tile_id: tile.id, section: params[:section]}, current_user)
      email_clicked_ping(current_user) if current_user
    end

    def find_board_for_guest
      @demo ||= @tile.demo
    end

    def get_sorted_explore_tiles
      ids = params[:tile_ids].map(&:to_i)
      default_sorting = Tile.where(id: ids).group_by(&:id)
      ids.map { |id| default_sorting[id].first }
    end

    def find_tile
      begin
        @tile ||= Tile.explore.find(params[:id])
      rescue
        not_found
      end
    end

    def next_explore_tile(offset)
      next_tile = @tiles[@tiles.index(@tile).to_i + offset] || @tiles.first
      next_tile || @tile
    end
end
