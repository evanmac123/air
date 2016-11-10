# require Rails.root.join('app/presenters/tile_preview/intros_presenter')

class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_tile
  before_filter :authorize_by_explore_token

  before_filter :allow_guest_user
  before_filter :login_as_guest_to_tile_board
  before_filter :authorize_as_guest

  layout "client_admin_layout"

  include LoginByExploreToken
  include ExploreHelper

  def show
    @tiles = params[:tile_ids] ? get_sorted_explore_tiles : Tile.copyable.verified_explore
    @next_tile = next_explore_tile(1)
    @prev_tile = next_explore_tile(-1)
    schedule_mixpanel_pings(@tile)

    if params[:partial_only]
      explore_preview_copy_intro
      render partial: "tile_previews/tile_preview",
             locals: { tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile, section: params[:section] },
             layout: false
    else
      @show_explore_intro = current_user.intros.show_explore_intro!
      explore_preview_copy_intro unless @show_explore_intro
      explore_intro_ping @show_explore_intro, params
      render "show", layout: "single_tile_guest_layout" if  logged_in_as_guest?
    end
  end

  private

    def schedule_mixpanel_pings(tile)
      ping("Tile - Viewed in Explore", {tile_id: tile.id, section: params[:section]}, current_user)
      ping('Tile - Viewed', {tile_type: "Public Tile - Explore", tile_id: tile.id}, current_user)

      if current_user.present?
        email_clicked_ping(current_user)
      end
    end

    def find_current_board
      @tile.demo
    end

    def get_sorted_explore_tiles
      ids = params[:tile_ids].map(&:to_i)
      default_sorting = Tile.where(id: ids).group_by(&:id)
      ids.map { |id| default_sorting[id].first }
    end

    def explore_preview_copy_intro
      @show_explore_preview_copy_intro = current_user.intros.show_explore_preview_copy!
    end

    def find_tile
      @tile = Tile.copyable.where(id: params[:id]).first

      unless @tile
        not_found
        return
      end
    end

    def login_as_guest_to_tile_board
      if current_user.nil?
        login_as_guest(@tile.demo)
      end
    end

    def next_explore_tile(offset)
      next_tile = @tiles[@tiles.index(@tile) + offset] || @tiles.first
      next_tile || @tile
    end
end
