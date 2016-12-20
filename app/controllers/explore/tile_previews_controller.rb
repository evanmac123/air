class Explore::TilePreviewsController < ApplicationController
  prepend_before_filter :find_tile
  prepend_before_filter :allow_guest_user

  layout "client_admin_layout"

  include LoginByExploreToken
  include ExploreHelper

  def show
    @tiles = params[:tile_ids] ? get_sorted_explore_tiles : Tile.explore.verified_explore
    @next_tile = next_explore_tile(1)
    @prev_tile = next_explore_tile(-1)
    schedule_mixpanel_pings(@tile)

    if request.xhr?
      render partial: "explore/tile_previews/tile_preview",
             locals: { tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile, section: params[:section] },
             layout: false
    else
      render "show", layout: "single_tile_guest_layout" if  logged_in_as_guest?
    end
  end

  private

    def schedule_mixpanel_pings(tile)
      ping("Tile - Viewed in Explore", {tile_id: tile.id, section: params[:section]}, current_user)

      if current_user.present?
        email_clicked_ping(current_user)
      end
    end

    def find_current_board
      @current_board ||= @tile.demo
    end

    def get_sorted_explore_tiles
      ids = params[:tile_ids].map(&:to_i)
      default_sorting = Tile.where(id: ids).group_by(&:id)
      ids.map { |id| default_sorting[id].first }
    end

    def find_tile
      @tile ||= Tile.explore.find(params[:id])
    end

    def next_explore_tile(offset)
      next_tile = @tiles[@tiles.index(@tile).to_i + offset] || @tiles.first
      next_tile || @tile
    end
end
