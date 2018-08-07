# frozen_string_literal: true

class Api::ClientAdmin::TilesController < Api::ClientAdminBaseController
  def index
    board = params[:demo].to_i > 0 ? Demo.find(params[:demo].to_i) : nil
    render json: Tile.display_explore_campaigns(board)
  end
end
