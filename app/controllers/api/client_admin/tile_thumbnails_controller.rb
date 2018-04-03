# frozen_string_literal: true

class Api::ClientAdmin::TileThumbnailsController < Api::ClientAdminBaseController
  def index
    @tiles = get_tiles

    content = render_to_string(
      formats: [:html],
      partial: "client_admin/tiles/manage_tiles/tiles_table",
      locals: { tiles: @tiles }
    )

    render json: {
      content: content,
      page: @tiles.current_page,
      nextPage: @tiles.next_page,
      lastPage: @tiles.last_page? || @tiles.empty?
    }
  end

  private

    def get_tiles
      ClientAdmin::TilesFilterer.call(demo: current_user.demo, params: filter_params)
    end

    def filter_params
      params.permit(:status, :month, :year, :campaign, :sort, :page)
    end
end
