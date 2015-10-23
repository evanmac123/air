class TopicsController < ClientAdminBaseController
  include TileBatchHelper
  include LoginByExploreToken
  include ExploreHelper

  before_filter :find_topic
  before_filter :find_tiles
  before_filter :set_all_tiles_displayed
  before_filter :limit_tiles_to_batch_size
  before_filter :find_liked_and_copied_tile_ids

  def show

    @tile_tags = @topic.tile_tags.alphabetical # TileTag.alphabetical.with_public_non_draft_tiles.where(topic: @topic)
    @path_for_more_tiles = explore_topic_path(@topic)
    render_partial_if_requested(tag_click_source: "Explore Topic Page - Clicked Tag On Tile", thumb_click_source: 'Explore Topic Page - Tile Thumbnail Clicked')
  end

  protected

  def find_topic
    @topic = Topic.find(params[:id])
  end

 def find_tiles
   #FIXME remove duplication
    @eligible_tiles = Tile.viewable_in_public.tagged_with(find_tile_tags)

    @tiles = @eligible_tiles.
      order("position asc").
      offset(offset).
      includes(:creator).
      includes(:tile_tags).
      includes(:demo)
  end

  def find_tile_tags
    @topic.tile_tags.pluck(:id).push(-1)
  end
end
