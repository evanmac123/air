# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    board = Demo.find(params[:demo].to_i) if params[:demo].to_i > 0
    render json: Tile.display_explore_campaigns(board)
  end

  def show
    render json: Campaign.find(params[:id]).react_sanitize_tiles(params[:page])
  end
end
