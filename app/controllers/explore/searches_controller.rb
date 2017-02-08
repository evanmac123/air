class Explore::SearchesController < ExploreBaseController
  layout 'search_layout'

  def show
    # # basics
    # search = AirboSearch.new('health insurance', demo)
    # @my_tiles = search.my_tiles
    # @explore_tiles = search.explore_tiles
    # @campaigns = search.campaigns
    # @organizations = search.organizations
    #
    # # pagination
    # search = AirboSearch.new('health insurance', demo)
    # @my_tiles_page_1 = search.my_tiles
    # @my_tiles_page_2 = search.my_tiles(2)
    # @my_tiles_page_7 = search.my_tiles(7)
    # @explore_tiles_page_3 = search.explore_tiles(3)
    #
    # # customize number of results per page
    # search = AirboSearch.new('health insurance', demo, { per_page: 24 })
    # @my_tiles_page_2 = search.my_tiles(2)

    @search_service = AirboSearch.new(params[:query], current_user)

    if request.xhr? && params[:section]
      content = render_to_string(
                  partial: 'shared/tiles/contextual_tiles',
                  locals: { tiles: tiles_to_render, presenter: presenter_to_render })

      render json: {
        success:   true,
        content:   content,
        added:     tiles_to_render.count,
        lastBatch: params[:count] == tiles_to_render.total_count.to_s,
        page: params[:page]
      }
    end
  end

  private

    def search_section
      case params[:section]
      when "client_admin_tiles"
        { tiles_to_render: "user_tiles", presenter_to_render: SingleAdminTilePresenter }
      when "explore_tiles"
      when "user_tiles"
        { tiles_to_render: "user_tiles", presenter_to_render: SingleTilePresenter }
      end
    end

    def tiles_to_render
      @search_service.send(search_section[:tiles_to_render], params[:page])
    end

    def presenter_to_render
      search_section[:presenter_to_render]
    end
end
