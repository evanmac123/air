class ExploreController < ExploreBaseController
  before_filter :set_intro_slides

  def show
    @tiles = Tile.explore_without_featured_tiles.page(params[:page]).per(28)

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
    end
  end

  def search
    # # basics
    # search = ClientAdminSearch.new('health insurance', demo)
    # @my_tiles = search.my_tiles
    # @explore_tiles = search.explore_tiles
    # @campaigns = search.campaigns
    # @organizations = search.organizations
    # 
    # # pagination
    # search = ClientAdminSearch.new('health insurance', demo)
    # @my_tiles_page_1 = search.my_tiles
    # @my_tiles_page_2 = search.my_tiles(2)
    # @my_tiles_page_7 = search.my_tiles(7)
    # @explore_tiles_page_3 = search.explore_tiles(3)
    #
    # # customize number of results per page
    # search = ClientAdminSearch.new('health insurance', demo, { per_page: 24 })
    # @my_tiles_page_2 = search.my_tiles(2)

    current_board = current_user.demo

    @service = ClientAdminSearch.new(params[:q], current_board)
  end

  private

    def set_intro_slides
      if show_slides?
        cookies[:airbo_explore] = Time.now
        @show_explore_onboarding = true
      end
    end

    def show_slides?
      if current_user.is_a?(User)
        params[:show_explore_onboarding]
      else
        !cookies[:airbo_explore]
      end
    end
end
