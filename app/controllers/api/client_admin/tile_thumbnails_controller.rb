# frozen_string_literal: true

class Api::ClientAdmin::TileThumbnailsController < Api::ClientAdminBaseController
  def index
    @tiles = get_tiles

    content = render_to_string(
      formats: [:html],
      partial: "client_admin/tiles/manage_tiles/tiles_table",
      locals: { tiles: Tile::PlaceholderManager.call(@tiles) }
    )

    render json: {
      content: content,
      page: @tiles.current_page,
      nextPage: @tiles.next_page,
      lastPage: @tiles.last_page?
    }
  end

  private

    def get_tiles
      current_user.demo.tiles.where(status: params[:status]).order(status: :desc).ordered_by_position.page(params[:page]).per(16)
    end
end
