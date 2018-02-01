# frozen_string_literal: true

class Explore::CampaignsController < ExploreBaseController
  def show
    @campaign = find_campaign
    @tiles = @campaign.tiles.page(params[:page]).per(28)
    if request.xhr?
      content = render_to_string(
        partial: "explore/tiles",
        locals: { tiles: @tiles, section: "Campaign" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
      }
    else
      @related_campaigns = @campaign.similar(fields: [:name, :tile_headlines, :tile_content])
      @display_channels = Channel.display_channels
    end
  end

  private

    def find_campaign
      Campaign.find(params[:id].to_i)
    end
end
