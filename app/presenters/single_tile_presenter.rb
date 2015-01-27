class SingleTilePresenter
  include ActionView::Helpers::NumberHelper
  include TileFooterTimestamper

  def initialize tile, format, type = nil
    @tile = tile
    @type = type
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

  def timestamp format = :html
    @timestamp ||= footer_timestamp
  end

  def completion_percentage
    @completion_percentage ||= number_to_percentage claimed_completion_percentage, precision: 1
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
            to: :tile
end