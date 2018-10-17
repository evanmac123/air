# frozen_string_literal: true

class ExploreController < ExploreBaseController
  def show
    @ctrl_data = {
      "currentBoard" => current_board.try(:id),
      "isGuestUser" => current_user.is_a?(GuestUser),
      "isEndUser" => current_user.end_user?,
      "latestTile" => Tile.includes(:campaign)
                          .where("status" => "active")
                          .where.not("campaigns.id" => nil)
                          .order(updated_at: :desc).first
                          .try(:updated_at),
     "missingThumbPath" => ActionController::Base.helpers.asset_path("missing-tile-img-thumb.png")
    }.to_json
    if request.xhr?
      render_json_tiles
    else
      explore_email_clicked_ping if params[:email_type].present?
      render template: "react_spa/show"
    end
  end

  def path_not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  private

    def render_json_tiles
      @tiles ||= []
      total_count = @tiles.empty? ? 0 : @tiles.total_count.to_s
      content = render_to_string(
        partial: "explore/tiles",
        locals: { tiles: @tiles, section: "Explore" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == total_count
      }
    end

    def explore_email_clicked_ping
      properties = {
        email_type: params[:email_type],
        email_version: params[:email_version],
      }

      ping("Email clicked", properties, current_user)
    end
end
