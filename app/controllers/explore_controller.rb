# frozen_string_literal: true

class ExploreController < ExploreBaseController
  def show
    @tiles = Tile.explore_not_in_campaign.page(params[:page]).per(28)

    if request.xhr?
      render_json_tiles
    else
      explore_email_clicked_ping if params[:email_type].present?
      @campaigns = {
        private_campaigns: Campaign.private_explore(demo: current_board),
        related_campaigns: Campaign.public_explore.order(:name)
      }
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
