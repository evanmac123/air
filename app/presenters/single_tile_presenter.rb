class SingleTilePresenter
  include Rails.application.routes.url_helpers

  def initialize tile, params, type, is_ie
    @tile = tile
    @type = type # explore or user
    @params = params
    @is_ie = is_ie
  end

  def status
    type
  end

  def has_tile_stats?
    false
  end

  def has_tile_buttons?
    false
  end

  def has_activation_dates?
    false
  end

  def show_tile_path
    if type == 'explore'
      explore_tile_preview_path(self)
    else
      @params[:public_slug] ? public_tile_path(@params[:public_slug], self) : tile_path(self)
    end
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
      thumbnail,
      type,
      tile_id,
      headline,
      @is_ie
    ].join('-')
  end

  attr_reader :tile, :type
  delegate  :id,
            :thumbnail,
            :headline,
            :demo,
            to: :tile
end
