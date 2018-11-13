# frozen_string_literal: true

class Api::V1::TilesController < Api::ApiController
  before_action :verify_origin

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
      result = if params[:include_completion] == "true"
        get_tile_completion_data(tile, tile_show)
      else
        tile_show
      end
      render json: result
    end

    def get_tile_completion_data(tile, tile_show)
      sanitized_tile_completion = JSON.parse(tile.tile_completions.where(user: current_user).first.to_json)["tile_completion"]
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

    def verify_origin
      render json: {} unless request.xhr?
    end

    def schedule_viewed_tile_ping(tile)
      return unless tile.present?
      tile_type = tile.is_invite_spouse? ? "Spouse Invite" : "User"
      ping("Tile - Viewed", { tile_type: tile_type, tile_id: tile.id, board_type: tile.demo.customer_status_for_mixpanel }, current_user)
    end
end
