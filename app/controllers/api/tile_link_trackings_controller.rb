class Api::TileLinkTrackingsController < Api::ApiController
  def create
    @tile = Tile.where(id: params[:tile_id]).first

    if @tile.present? && track_click
      render json: { tile_id: @tile.id, data: @tile.raw_link_click_stats }, status: 200
    else
      render_json_access_denied
    end
  end

  private

    def track_click
      if current_user.is_a?(User) && params[:clicked_link].present?
        @tile.track_link_click(clicked_link: params[:clicked_link], user: current_user)
      end
    end
end
