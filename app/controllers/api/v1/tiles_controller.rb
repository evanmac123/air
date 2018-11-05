# frozen_string_literal: true

class Api::V1::TilesController < Api::ApiController
  before_action :verify_origin

  def show
    tile = Tile.find(params[:id])
    if params[:ping_tile_view] == 'true'
      schedule_viewed_tile_ping(tile)
      tile.viewed_by(current_user)
    end
    render_full_display(tile)
  end

  def ping_tile_view
    tile = Tile.find(params[:id])
    schedule_viewed_tile_ping(tile)
    tile.viewed_by(current_user)
    render json: {success: 'Pinged view'}
  end

  private
    def render_full_display(tile)
      render json: tile.sanitize_for_tile_show
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
