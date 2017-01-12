class Explore::OrganizationsController < ExploreBaseController
  def show
    @organization = Organization.find_by_slug(params[:id])
    @tiles = @organization.tiles.explore.page(params[:page]).per(28)

    if @tiles.present?
      if request.xhr?
        content = render_to_string(
                    partial: "explore/tiles",
                    locals: { tiles: @tiles, section: "Channel" })

        render json: {
          success:   true,
          content:   content,
          added:     @tiles.count,
          lastBatch: params[:count] == @tiles.total_count.to_s
        }
      else
        @display_channels = Channel.display_channels
      end
    else
      redirect_to(explore_path)
    end
  end
end
