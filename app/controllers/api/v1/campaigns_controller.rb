# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    board = params[:demo].to_i > 0 ? Demo.find(params[:demo].to_i) : nil
    render json: Tile.display_explore_campaigns(board)
  end

  def show
    render json: Campaign.find(params[:id]).react_sanitize_tiles(params[:page])
  end
end
