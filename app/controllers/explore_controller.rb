# frozen_string_literal: true

class ExploreController < ExploreBaseController
  def show
    @ctrl_data = {
      "isGuestUser" => current_user.is_a?(GuestUser),
      "isEndUser" => current_user.end_user?,
      "latestTile" => Tile.includes(:campaign)
                          .where("status" => "active")
                          .where.not("campaigns.id" => nil)
                          .order(created_at: :desc).first
                          .try(:created_at)
    }.to_json
    if request.xhr?
      render_json_tiles
    else
      explore_email_clicked_ping if params[:email_type].present?
    end
  end

  private

    def render_json_tiles
      content = render_to_string(
        partial: "explore/tiles",
        locals: { tiles: @tiles, section: "Explore" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
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
