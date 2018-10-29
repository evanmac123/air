# frozen_string_literal: true

class TilesController < ApplicationController
  include AllowGuestUsersConcern
  include AuthorizePublicBoardsConcern
  include TileBatchHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include ActsHelper
  include ThemingConcern

  before_action :set_theme, only: [:index]

  # FIXME FIXME this logic is sooooooo convoluted!!!!!
  # so I don't forget the next time i look at this crazy code
  # Index and show essentially do the same thing display a single tiles_path
  # index renders it in the slideshow
  # the first time around the else path is triggered and we render the index
  # template
  # the second time we render the partial via ajax.

  def index
    @demo = current_user.demo

    if params[:partial_only]
      render_tile_wall_as_partial
    elsif params[:from_search] == "true"
      @start_tile = current_board.tiles.find_by(id: params[:tile_id])
      @current_tile_ids = params[:tile_ids].split(", ")
    else
      # TODO: CLEAN THIS UP... Temporary code to deal with scaling issue
      # Fuji and other bigger, older clients are killing our PG memory
      # patching new React rendering to old code base for time being
      start_tile = find_start_tile

      if params[:tile_id] && start_tile.nil?
        redirect_to activity_path
      else
        @ctrl_data = {
          inPublicBoard: params[:public_slug].present?,
          startTile: start_tile ? start_tile.sanitize_for_tile_show : {},
          raffle: @demo.live_raffle.try(:id),
          tileType: show_completed_tiles ? "complete" : "incomplete",
          tileIds: tiles_to_be_loaded.pluck(:id)
        }.to_json

        schedule_viewed_tile_ping(start_tile)
        increment_tile_views_counter start_tile, current_user
        session.delete(:start_tile)

        render template: "react_spa/show"
      end
    end
  end

  def show
    if params[:from_search]
      render_search_tile_viewer
    elsif params[:partial_only]
      answered = params[:answered] || []
      after_posting = params[:afterPosting] == "true"
      all_tiles_done = params[:previous_tile_ids].split(",").length == answered.length
      render_single_tile_for_viewer(answered, after_posting, all_tiles_done)
    else
      session[:start_tile] = params[:id]
      if params[:public_slug]
        redirect_to public_tiles_path(params[:public_slug])
      else
        redirect_to tiles_path(tile_ids: params[:tile_ids], from_search: params[:from_search], tile_id: params[:id])
      end
    end
  end

  private

    def verify_tile_exists(start_tile = @start_tile)
      redirect_to activity_path if params[:tile_id] && start_tile.nil?
    end

    def find_start_tile
      start_tile = Tile.where(id: start_tile_id).first
      if start_tile.present? && tile_authorized?(start_tile)
        start_tile
      end
    end

    def start_tile_id
      params[:tile_id] || session[:start_tile] || first_id
    end

    def tile_authorized?(tile)
      tile.is_sharable || tile.demo_id == current_user.demo_id
    end

    def first_id
      tiles_to_be_loaded.first.try(:id)
    end

    def live_raffle?
      params[:raffle] && !params[:raffle].empty?
    end

    def mark_as_viewed
      schedule_viewed_tile_ping(current_tile)
      increment_tile_views_counter current_tile, current_user
    end

    def render_search_tile_viewer
      ping("Tile - Viewed in Search", { tile_id: params[:id], tile_type: "User" }, current_user)

      @start_tile = Tile.find(params[:id])
      render json: {
        tile_content: render_to_string("tiles/_search_viewer",  layout: false),
      }
    end

    def render_new_tile(after_posting, all_tiles_done)
      completed_tiles = params[:answered].try(:length) || 0
      render json: {
        ending_points: params[:totalPoints] || current_user.points,
        ending_tickets: live_raffle? ? current_user.tickets : 0,
        flash_content: render_to_string("shared/_flashes", layout: false),
        tile_content: tile_content(all_tiles_done, after_posting),
        all_tiles_done: all_tiles_done,
        show_start_over_button: current_user.can_start_over?,
        raffle_progress_bar: live_raffle? ? raffle_progress_bar * 10 : 0,
        all_tiles: params[:previous_tile_ids].split(",").length,
        completed_tiles: completed_tiles
      }
    end

    def render_single_tile_for_viewer(answered, after_posting, all_tiles_done)
      render_new_tile(after_posting, all_tiles_done)
      mark_as_viewed unless all_tiles_done && after_posting
      mark_all_completed_tiles if all_tiles_done
    end

    def tile_content(all_tiles_done, after_posting)
      if all_tiles_done && after_posting
        render_to_string("tiles/_all_tiles_done", layout: false)
      else
        @start_tile = current_tile
        render_to_string("tiles/_viewer",  layout: false)
      end
    end

    def current_tile_index
      @idx ||= if tiles_to_be_loaded.empty?
        0
      elsif not previous_tile_ids.empty?
        (previous_tile_index + params[:offset].to_i) % (current_tile_ids.length > 0 ? current_tile_ids.length : 1)
      else
        (current_tile_ids.find_index { |element| element.to_i == reference_tile_id.to_i }) || 0
      end
    end

    def current_tile_id
      current_tile_ids[current_tile_index]
    end

    def current_tile
      if params[:fromSearch] == "true"
        current_tile_for_search
      else
        @tile ||= Tile.find(current_tile_id)
      end
    end

    def current_tile_for_search
      neighboring_tiles = params[:previous_tile_ids].split(",")
      if params[:offset] == "1"
        Tile.find(neighboring_tiles[-1])
      else
        Tile.find(neighboring_tiles[0])
      end
    end


    def current_tile_ids
      @current_tile_ids ||= begin
        not_completed_tile_ids = tiles_to_be_loaded.map(&:id)
        new_tile_ids = not_completed_tile_ids - previous_tile_ids
        current_tile_ids = previous_tile_ids + new_tile_ids
        current_tile_ids
      end
    end

    def previous_tile_ids
      @_previous_tile_ids ||= (params[:previous_tile_ids] && params[:previous_tile_ids].split(",").collect { |el| el.to_i }) || []
    end

    def reference_tile_id
      params[:id] || start_tile_id
    end

    def previous_tile_index
      (previous_tile_ids.find_index { |element| element.to_i == reference_tile_id.to_i }) || 0
    end


    def render_tile_wall_as_partial
      html_content = render_to_string partial: "shared/tile_wall", locals: (Tile.displayable_categorized_to_user(current_user, maximum_tiles_wanted)).merge(path_for_more_tiles: tiles_path(board_id: params[:board_id]))
      render json: { htmlContent: html_content }
    end

    def user_started_on_completed_tile?
      session[:start_tile] && current_user.tile_completions.where(tile_id: session[:start_tile]).exists?
    end

    def show_completed_tiles
      @show_completed_tiles ||= (params[:completed_only] == "true") || user_started_on_completed_tile?
    end

    def user_tiles_to_complete
      current_user.tiles_to_complete_in_demo
    end

    def tiles_to_be_loaded
      if show_completed_tiles
        current_user.completed_tiles_in_demo
      else
        user_tiles_to_complete
      end
    end

    def schedule_viewed_tile_ping(tile)
      return unless tile.present?
      tile_type = tile.is_invite_spouse? ? "Spouse Invite" : "User"
      ping("Tile - Viewed", { tile_type: tile_type, tile_id: tile.id, board_type: tile.demo.customer_status_for_mixpanel }, current_user)
    end

    def maximum_tiles_wanted
      offset = params[:offset].to_i
      offset + tile_batch_size - (offset % tile_batch_size)
    end

    def mark_all_completed_tiles
      current_user.not_show_all_completed_tiles_in_progress
    end

    def increment_tile_views_counter(tile, user)
      tile.viewed_by(user) if tile
    end
end
