class Explore::SearchesController < ExploreBaseController
  layout 'search_layout'

  def show
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

    service = ClientAdminSearch.new(params[:q], current_board)
    @my_tiles = service.my_tiles(params[:my_tiles_page])
    @explore_tiles = service.explore_tiles(params[:explore_tiles_page])

    @campaigns = service.campaigns
    @organizations = service.organizations
  end
end
