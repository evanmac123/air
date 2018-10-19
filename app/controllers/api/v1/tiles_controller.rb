# frozen_string_literal: true

class Api::V1::TilesController < Api::ApiController
  before_action :verify_origin

  def show
    tile = Tile.find(params[:id])
    render_full_display(tile)
  end

  private
    def render_full_display(tile)
      render json: tile.sanitize_for_tile_show
    end

    def verify_origin
      render json: {} unless request.xhr?
    end
end
