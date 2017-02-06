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

    @search_service = AirboSearch.new(params[:query], current_user, { page: requested_page })
  end

  private

    def requested_page
      params[:page] || 1
    end
end
