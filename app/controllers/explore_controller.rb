class ExploreController < ExploreBaseController
  include TileBatchHelper
  include ExploreHelper

  def show
    find_tiles_and_campaigns
    @path_for_more_content = explore_path

    render_partial_if_requested
  end
end
