# frozen_string_literal: true

class ExploreController < ExploreBaseController
  def show
    @tiles = Tile.explore.page(params[:page]).per(28)

    if request.xhr?
      content = render_to_string(
        partial: "explore/tiles",
        locals: { tiles: @tiles, section: "Explore" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
      }
    else
      explore_email_clicked_ping if params[:email_type].present?
      @related_campaigns = Campaign.order(:name)
    end
  end

  private

    def explore_email_clicked_ping
      properties = {
        email_type: params[:email_type],
        email_version: params[:email_version],
      }

      ping("Email clicked", properties, current_user)
    end
end
