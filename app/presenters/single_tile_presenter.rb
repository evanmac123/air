class SingleTilePresenter
  include ActionView::Helpers::NumberHelper
  include TileFooterTimestamper 
  include Rails.application.routes.url_helpers

  def initialize tile, format
    @tile = tile
    @type = tile.status.to_sym
    @format = format
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

  def has_undo_ignore_button?
    type? :ignored
  end

  def has_additional_tile_stats?
    type? :active, :archive
  end

  def shows_creator?
    type? :user_submitted
  end

  def has_tile_stats?
    type? :draft, :active, :archive, :user_submitted, :ignored
  end

  def show_tile_path
    if type? :user_draft, :user_submitted
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
