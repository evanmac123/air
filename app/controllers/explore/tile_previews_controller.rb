# frozen_string_literal: true

class Explore::TilePreviewsController < ExploreBaseController
  prepend_before_action :find_tile

  def show
    schedule_mixpanel_pings
    if request.xhr?
      render_tile_preview_modal
    else
      render_single_tile_page
    end
  end

  private

    def render_tile_preview_modal
      set_next_prev_tiles
      render partial: "explore/tile_previews/tile_preview",
        locals: { tile: @tile, next_tile: @next_tile, prev_tile: @prev_tile, section: params[:section] },
        layout: false
    end

    def render_single_tile_page
      @explore_or_public = :explore
      render "single_explore_tile", layout: "single_tile_base_layout"
    end

    def schedule_mixpanel_pings
      if params[:from_search]
        ping("Tile - Viewed in Search", { tile_id: tile_id, tile_type: "Explore" }, current_user)
      else
        ping("Tile - Viewed in Explore", { tile_id: tile_id, section: params[:section] }, current_user)
      end
    end

    def set_next_prev_tiles
      @next_tile = params[:next_tile] || tile_id
      @prev_tile = params[:prev_tile] || tile_id
    end

    def find_board_for_guest
      @demo ||= @tile.try(:demo)
    end

    def find_tile
      id = params[:id]
      @tile = Tile.explore.find_by(id: id) || current_org_tiles.find(id)
    end

    def tile_id
      @tile.id
    end

    def current_org_tiles
      current_board.organization.tiles
    end
end
