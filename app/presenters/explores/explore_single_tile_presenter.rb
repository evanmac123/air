require 'new_relic/agent/method_tracer'

class ExploreSingleTilePresenter
  include ActionView::Helpers::TextHelper
  include ::NewRelic::Agent::MethodTracer

  def initialize(tile, tile_tag, user_copied_tile, user_liked_tile)
    nr_trace("ESTP -- tile") {@tile = tile}
    nr_trace("ESTP -- UCT") {@user_copied_tile = user_copied_tile}
    nr_trace("ESTP -- ULT") {@user_liked_tile = user_liked_tile}
    nr_trace("ESTP -- tag") {@tile_tag = tile_tag}
  end

  def tile_id
    @tile_id ||= tile.id
  end

  def copy_count
    @copy_count ||= tile.copy_count
  end

  def like_count
    @like_count ||= tile.like_count
  end

  def like_count_if_nonzero
    if @like_count > 0
      @like_count.to_s
    else
      ''
    end
  end

  def copy_link_text
    @copy_link_text ||= (user_copied_tile ? 'Copied' : 'Copy')
  end

  def like_links_class
    @like_links_class ||= "tile-#{tile_id}"
  end

  def display_liked
    @display_liked ||= user_liked_tile ? 'display:block' : 'display:none'
  end

  def display_unliked
    @display_unliked ||= user_liked_tile ? 'display:none' : 'display:block'
  end

  def tile_not_copyable
    @tile_not_copyable ||= !(tile.is_copyable?)
  end

  def explore_tile_likes_path_params
    { tile_id: tile_id, path: via_subject_or_thumbnail, remote: true }
  end

  def thumbnail_id
    @thumbnail_id ||= "tile-thumbnail-#{tile_id}"
  end

  def containing_td_id
    @containing_td_id ||= "tile-thumbnail-container-#{tile_id}"
  end

  def thumbnail_url
    @thumbnail_url ||= tile.thumbnail.to_s
  end

  def full_size_url
    @full_size_url ||= tile.image.url
  end

  def truncated_client_or_board_name
    @truncated_client_or_board_name ||= begin
      name_to_truncate = board.client_name.present? ? board.client_name : board.name
      truncate(name_to_truncate, length: 22)
    end
  end

  def tile_tag_id_if_present
    tile_tag.try(:id).to_s
  end

  def to_param
    @to_param ||= tile.to_param
  end

  def headline
    @headline ||= tile.headline
  end

  def creator_name
    @creator_name ||= if !tile.nil? && !tile.creator.nil? && tile.creator.name?
                        tile.creator.name
                      else
                        ''
                      end
  end

  def board_name
    @board_name ||= if !board.nil? && board.name?
                      board.name
                    else
                      ''
                    end
  end

  def associated_tile_tags
    @associated_tile_tags ||= tile.tile_tags.uniq
  end

  def associated_tile_tag_keys
    @associated_tile_tag_keys ||= associated_tile_tags.sort_by(&:id).map{|tile_tag| [tile_tag.title, tile_tag.id]}.join('-')
  end

  def cache_key
    @cache_key ||= [
      self.class.to_s, 
      'v5.pwd',
      tile_id, 
      copy_link_text, 
      copy_count, 
      user_copied_tile, 
      user_liked_tile, 
      tile_not_copyable,
      tile_tag_id_if_present,
      like_count,
      thumbnail_id,
      thumbnail_url,
      truncated_client_or_board_name,
      headline,
      creator_name,
      board_name,
      associated_tile_tag_keys,
      containing_td_id
    ].join('-')
  end

  attr_reader :user_copied_tile

  add_method_tracer :cache_key
  add_method_tracer :thumbnail_id
  add_method_tracer :thumbnail_url
  add_method_tracer :containing_td_id
  add_method_tracer :truncated_client_or_board_name
  add_method_tracer :to_param
  add_method_tracer :like_links_class
  add_method_tracer :display_liked
  add_method_tracer :like_count
  add_method_tracer :explore_tile_likes_path_params
  add_method_tracer :display_unliked
  add_method_tracer :like_count_if_nonzero
  add_method_tracer :user_copied_tile
  add_method_tracer :tile_not_copyable
  add_method_tracer :copy_count
  add_method_tracer :copy_link_text
  add_method_tracer :headline
  add_method_tracer :creator_name
  add_method_tracer :board_name
  add_method_tracer :associated_tile_tags
  add_method_tracer :full_size_url

  protected

  attr_reader :tile, :user_liked_tile, :tile_tag

  def via_subject_or_thumbnail
    tile_tag ? :via_explore_page_subject_tag : :via_explore_page_thumbnail
  end

  def board
    @board ||= tile.demo
  end

  def nr_trace(tag)
    self.class.trace_execution_scoped([tag]) do
      yield
    end
  end
end
