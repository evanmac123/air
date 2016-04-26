class TopicsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  before_filter :find_topic
  before_filter :find_tiles
  before_filter :set_all_tiles_displayed
  before_filter :limit_tiles_to_batch_size

  def show
    @tiles = @tiles.reorder("position desc")
    @tile_tags = @topic.tile_tags.alphabetical.rearrange_by_other
    @path_for_more_tiles = explore_topic_path(@topic)
    render_partial_if_requested
  end

  protected
    def find_topic
      @topic = Topic.find(params[:id])
    end

    def find_tile_tags
      @topic.tile_tags.pluck(:id).push(-1)
    end
end
