class SingleTilePresenter < BasePresenter

  attr_reader :tile, :type
  delegate  :id,
            :thumbnail,
            :headline,
            :demo,
            to: :tile

  presents :tile

  def initialize object,template, options 
    super

    @type = options[:type] # explore or user
    @public_slug = options[:public_slug]
    @completed = options[:completed]
  end

  def tile_id
    @tile_id ||= id
  end

  def to_param
    @to_param ||= tile.to_param
  end

  def status
    type
  end

  def completed_class
    if @completed.nil?
      ""
    elsif @completed
      "completed"
    else
      "not-completed"
    end
  end

  def has_tile_buttons?
    false
  end

  def activation_dates
    #noop
  end

  def has_tile_stats?
    false
  end

  def show_tile_path
    if type == 'explore'
      explore_tile_preview_path(self)
    else
      @public_slug ? public_tile_path(@public_slug, tile) : tile_path(tile)
    end
  end



  def cache_key
    @cache_key ||= [
      self.class,
      'v2.ant',
      thumbnail,
      type,
      tile_id,
      headline,
      @is_ie,
      @completed
    ].join('-')
  end
end
