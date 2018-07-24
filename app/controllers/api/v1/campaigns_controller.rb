# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    board = params[:demo].to_i > 0 ? Demo.find(params[:demo].to_i) : nil
    render json: Tile.display_explore_campaigns(board)
  end

  def show
    campaign_tiles = Campaign.find(params[:id]).tiles_for_page(params[:page])
    render json: Tile.react_sanitize(campaign_tiles)
  end
end
