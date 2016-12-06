class SingleAdminTilePresenter < BasePresenter

  include TileFooterTimestamper
  delegate  :id,
            :status,
            :thumbnail,
            :headline,
            :active?,
            :total_views,
            :unique_views,
            :thumbnail_processing,
            :tile_completions_count,
            :original_creator,
            :demo,
            :is_placeholder?,
            to: :tile
  attr_reader :tile, :type, :tiles_grouped_ids, :section

  presents :tile

  def initialize object,template, options
    super
    @type = get_type(options[:page_type])
    @tiles_grouped_ids = options[:tile_ids]
    @format =  options[:format]||:html
    @section = options[:section]
  end

  def tile_id
    @tile_id ||= id
  end

  def copied?
    $redis.sismember("Demo:#{current_user.demo_id}:copies", tile_id)
  end

  def get_type(page_type)
    page_type ? page_type : tile.status.to_sym
  end

  def type? *types
    if types.size == 0
      false
    elsif types.size == 1
      type == types.first
    else
      types.any? {|t| t == type}
    end
  end

  def completed_class
    ""
  end

  def has_tile_buttons?
    true
  end

  def activation_dates
    if type? :active, :archive, :draft, :user_submitted, :ignored
      content_tag :div, raw(timestamp), class: "activation_dates"
    end
  end

  def has_tile_stats?
    type? :active, :archive
  end

  def show_tile_path
    if type == :explore
      explore_tile_preview_path(self, tile_ids: tiles_grouped_ids, section: section)
    else
      client_admin_tile_path(tile)
    end
  end

  def has_archive_button?
    type? :active
  end

  def has_activate_button?
    type? :archive, :draft
  end

  def post_link_text
    'Post' + (type?(:archive) ? ' again' : '')
  end

  def has_edit_button?
   type? :draft, :active, :archive
  end

  def has_destroy_button?
   type? :draft, :active, :archive
  end

  def has_accept_button?
    type? :user_submitted
  end

  def has_ignore_button?
    type? :user_submitted
  end

  def has_copy_button?
    type? :explore
  end

  def has_undo_ignore_button?
    type? :ignored
  end

  def has_menu?
    type? :draft, :active, :archive
  end

  def shows_creator?
    type? :user_submitted
  end

  def timestamp
    @timestamp ||= footer_timestamp
  end

  def completion_percentage
    @completion_percentage ||=
      number_to_percentage claimed_completion_percentage, precision: 1
  end

  def claimed_completion_percentage
    100.0 * tile_completions_count / demo.users.claimed.count
  end

  def has_creator?
    original_creator
  end

  def creator
    original_creator.name
  end

  def tile_position
   @tile.position || 0
  end

  def to_param
    @to_param ||= tile.to_param
  end


  def cache_key
    @cache_key ||= [
      self.class,
      'v2.ant',
      timestamp,
      thumbnail,
      type,
      tile_id,
      headline,
      tile_completions_count,
      total_views,
      unique_views,
      @is_ie,
      copied?,
      section
    ].join('-')
  end


end
