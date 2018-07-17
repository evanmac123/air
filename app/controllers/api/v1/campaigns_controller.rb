# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    render json: Tile.display_explore_campaigns
  end

  def show
    render json: Campaign.find(params[:id]).react_sanitize_tiles(params[:page])
  end
end
