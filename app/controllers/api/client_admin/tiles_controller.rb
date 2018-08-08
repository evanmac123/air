# frozen_string_literal: true

class Api::ClientAdmin::TilesController < Api::ClientAdminBaseController
  def index
    render json: Tile.fetch_edit_flow(current_board)
  end
end
