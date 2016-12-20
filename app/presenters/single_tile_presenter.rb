class SingleTilePresenter < BasePresenter

  attr_reader :tile, :tile_status :user_onboarding
  delegate  :id,
            :thumbnail,
            :headline,
            :demo,
            to: :tile

  presents :tile

  def initialize(object, template, options)
    super
    @type = options[:type] # explore or user
    @public_slug = options[:public_slug]
    @completed = options[:completed]
    @user_onboarding = options[:user_onboarding]
  end

  def tile_id
    @tile_id ||= id
  end

  #this method is redundant as to_param is notset for Tile, so it just returns id
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
    type == 'explore'
  end

  def activation_dates
    #noop
  end

  def has_tile_stats?
    false
  end

  def show_tile_path
    if user_onboarding
      user_onboarding_tile_path(user_onboarding, tile)
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
      @completed,
      @type,
      @public_slug
    ].join('-')
  end
end
