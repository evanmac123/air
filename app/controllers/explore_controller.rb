class ExploreController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  def show
    find_tiles_and_campaigns
    @path_for_more_content = explore_path
    binding.pry
    render_partial_if_requested
  end
end
