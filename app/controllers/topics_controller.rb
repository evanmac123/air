class TopicsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  before_filter :find_tiles
  before_filter :set_all_tiles_displayed
  before_filter :limit_tiles_to_batch_size
  before_filter :find_liked_and_copied_tile_ids

  def show
    @topic = Topic.find(params[:id])
    @tile_tags = TileTag.alphabetical.with_public_non_draft_tiles.where(topic: @topic)
    @path_for_more_tiles = explore_topic_path(@topic)
    # render_partial_if_requested
  end

  protected

  # def eligible_tiles
  #
  # end
end
