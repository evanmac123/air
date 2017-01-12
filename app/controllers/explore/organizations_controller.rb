class Explore::OrganizationsController < ExploreBaseController
  def show
    if find_organization && get_tiles
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
      set_flash
      redirect_to(explore_path)
    end
  end

  private

    def find_organization
      @organization = Organization.find_by_slug(params[:id])
    end

    def get_tiles
      @tiles = @organization.tiles.explore.page(params[:page]).per(28)
    end

    def set_flash
      unless @organization
        flash[:failure] = t("controllers.explore.organizations.failure_when_org_not_found")
      end
    end
end
