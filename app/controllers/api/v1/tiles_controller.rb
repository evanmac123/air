# frozen_string_literal: true

class Api::V1::TilesController < Api::ApiController
  before_action :verify_origin

  def index
    tiles = Tile.displayable_categorized_to_user(
      user: current_user || find_user_with_params,
      maximum_tiles: params[:maximum_tiles].to_i,
      current_board: current_user.try(:demo),
      page: current_page,
      offset: params[:offset].to_i
    )
    render json: sanitize_group(tiles)
  end

  def show
    tile = Tile.find(params[:id])
    if params[:ping_tile_view] == "true"
      schedule_viewed_tile_ping(tile)
      tile.viewed_by(current_user)
    end
    render_full_display(tile)
  end

  def ping_tile_view
    tile = Tile.find(params[:id])
    schedule_viewed_tile_ping(tile)
    tile.viewed_by(current_user)
    render json: { success: "Pinged view" }
  end

  private
    def render_full_display(tile)
      tile_show = tile.sanitize_for_tile_show
      tile_completion = params[:include_completion] == "true" ? tile.tile_completions.where(user: current_user).first : nil
      result = if tile_completion
        get_tile_completion_data(tile_completion, tile_show)
      else
        tile_show
      end
      render json: result
    end

    def get_tile_completion_data(tile_completion, tile_show)
      sanitized_tile_completion = JSON.parse(tile_completion.to_json)["tile_completion"]
      parsed_tile_completion = sanitized_tile_completion.keys.reduce({}) do |result, key|
        case key
        when "answer_index"
          result[:answerIndex] = sanitized_tile_completion[key]
        when "free_form_response"
          result[:freeFormResponse] = sanitized_tile_completion[key]
        end
        result
      end.merge(complete: true)
      tile_show.merge(parsed_tile_completion)
    end

    def schedule_viewed_tile_ping(tile)
      return unless tile.present?
      tile_type = tile.is_invite_spouse? ? "Spouse Invite" : "User"
      ping("Tile - Viewed", { tile_type: tile_type, tile_id: tile.id, board_type: tile.demo.customer_status_for_mixpanel }, current_user)
    end

    def sanitize_group(tiles)
      complete = tiles[:completed_tiles] || []
      incomplete = tiles[:not_completed_tiles] || []
      {
        tiles: {
          complete:          complete.map { |tile| tile.sanitize_for_tile_show.merge(fullyLoaded: true) },
          incomplete:        incomplete.map { |tile| tile.sanitize_for_tile_show.merge(fullyLoaded: true) },
        },
        completeTilesPage:   tiles[:complete_tiles_page],
        incompleteTilesPage: tiles[:incomplete_tiles_page],
        completeTilesOffset: tiles[:offset],
        allTilesDisplayed:   tiles[:all_tiles_displayed]
      }
    end

    def current_page
      {
        complete_tiles_page: params[:complete_tiles_page].to_i,
        incomplete_tiles_page: params[:incomplete_tiles_page].to_i,
      }
    end
end
