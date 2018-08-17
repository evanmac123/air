# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    board = params[:demo].to_i > 0 ? Demo.find(params[:demo].to_i) : nil
    render json: Tile.display_explore_campaigns(board)
  end

  def show
    campaign_tiles = Campaign.find(params[:id]).tiles_for_page(params[:page])
    result = Tile.react_sanitize(campaign_tiles, 27) do |tile|
      id = tile.id
      {
        "copyPath" => "/explore/copy_tile?path=via_explore_page_tile_view&tile_id=#{id}",
        "tileShowPath" => "/explore/tile/#{id}",
        "headline" => tile.headline,
        "id" => id,
        "created_at" => tile.created_at,
        "thumbnail" => tile.thumbnail_url,
        "thumbnailContentType" => tile.thumbnail_content_type
      }
    end
    render json: result
  end
end
