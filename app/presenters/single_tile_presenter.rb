class SingleTilePresenter
  include ActionView::Helpers::NumberHelper
  include TileFooterTimestamper 
  include Rails.application.routes.url_helpers

  def initialize tile, format, as_admin
    @tile = tile
    @type = tile.status.to_sym
    @format = format
    @as_admin = as_admin
  end

  def is_placeholder?
    false
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

  def has_archive_button?
    show_admin_buttons? && (type? :active)
  end

  def has_activate_button?
    show_admin_buttons? && (type? :archive, :draft)
  end

  def post_link_text
    'Post' + (type?(:archive) ? ' again' : '')
  end

  def has_edit_button?
    show_admin_buttons? && (type? :draft, :active, :archive)
  end

  def has_destroy_button? 
    show_admin_buttons? && (type? :draft, :active, :archive)
  end

  def has_accept_button? 
    show_admin_buttons? && (type? :user_submitted)
  end

  def has_ignore_button? 
    show_admin_buttons? && (type? :user_submitted)
  end

  def has_undo_ignore_button?
    show_admin_buttons? && (type? :ignored)
  end

  def has_additional_tile_stats?
    show_admin_buttons? && (type? :active, :archive)
  end

  def shows_creator?
    type? :user_submitted
  end

  def has_tile_stats?
    type? :draft, :active, :archive, :user_submitted, :ignored
  end

  def show_tile_path
    if viewing_as_regular_user?
      suggested_tile_path(self)
    else
      client_admin_tile_path(self)    
    end
  end

  def timestamp
    @timestamp ||= footer_timestamp
  end

  def completion_percentage
    @completion_percentage ||= 
      number_to_percentage claimed_completion_percentage, precision: 1
  end

  def has_creator?
    original_creator
  end

  def creator
    original_creator.name 
  end

  def tile_id
    @tile_id ||= id
  end

  def to_param
    @to_param ||= tile.to_param
  end

  def show_admin_buttons?
    @as_admin.present?
  end

  def viewing_as_regular_user?
    !@as_admin
  end

  def cache_key
    @cache_key ||= [
      self.class,
      'v2.ant',
      timestamp, 
      completion_percentage, 
      type, 
      tile_id, 
      thumbnail, 
      headline, 
      tile_completions_count, 
      total_views, 
      unique_views
    ].join('-')
  end

  attr_reader :tile, :type
  delegate  :id,
            :status, 
            :thumbnail, 
            :headline, 
            :active?,
            :total_views,
            :unique_views,
            :thumbnail_processing,
            :tile_completions_count, 
            :claimed_completion_percentage, 
            :original_creator,
            to: :tile
end
