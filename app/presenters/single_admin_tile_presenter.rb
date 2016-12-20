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
  attr_reader :tile, :tile_status, :tiles_grouped_ids

  presents :tile

  def initialize object,template, options
    super
    @tile_status = tile.status.to_sym
    @tiles_grouped_ids = options[:tile_ids]
    @format =  options[:format]||:html
  end

  def tile_id
    @tile_id ||= id
  end

  def tile_status_matches? *statuses
    if statuses.size == 0
      false
    elsif statuses.size == 1
      @tile_status == statuses.first
    else
      statuses.any? {|t| t == @tile_status}
    end
  end

  def completed_class
    ""
  end

  def has_tile_buttons?
    true
  end

  def activation_dates
    if tile_status_matches? :active, :archive, :draft, :user_submitted, :ignored
      content_tag :div, raw(timestamp), class: "activation_dates"
    end
  end

  def has_tile_stats?
    tile_status_matches? :active, :archive
  end

  def show_tile_path
    client_admin_tile_path(tile)
  end

  def has_archive_button?
    tile_status_matches? :active
  end

  def has_activate_button?
    tile_status_matches?(:archive, :draft) && tile.is_fully_assembled?
  end

  def has_disabled_activate_button?
    tile_status_matches?(:draft) && !tile.is_fully_assembled?
  end

  def has_working_button?
    tile_status_matches?(:draft) && !tile.is_fully_assembled?
  end



   def has_edit_button?
     tile_status_matches?(:draft, :active, :archive) && tile.is_fully_assembled?
  end

  def has_destroy_button?
   tile_status_matches? :draft, :active, :archive
  end

  def has_accept_button?
    tile_status_matches? :user_submitted
  end

  def has_ignore_button?
    tile_status_matches? :user_submitted
  end

  def has_copy_button?
    tile_status_matches? :explore
  end

  def has_undo_ignore_button?
    tile_status_matches? :ignored
  end

  def has_menu?
    tile_status_matches? :draft, :active, :archive
  end

  def shows_creator?
    tile_status_matches? :user_submitted
  end

  def post_link_text
    'Post' + (tile_status_matches?(:archive) ? ' again' : '')
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
      tile_status,
      tile_id,
      headline,
      tile_completions_count,
      total_views,
      unique_views,
      @is_ie
    ].join('-')
  end


end
