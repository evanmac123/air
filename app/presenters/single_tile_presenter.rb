class SingleTilePresenter < BasePresenter

  attr_reader :tile, :type, :user_onboarding
  delegate  :id,
            :thumbnail,
            :headline,
            :demo,
            :tile_completions_count,
            :media_source,
            :question_config,
            :has_attachments,
            :attachment_count,
            to: :tile

  presents :tile

  attr_reader :options

  def initialize(object, template, options)
    super
    @type = options[:type] # explore or user
    @public_slug = options[:public_slug]
    @completed = options[:completed]
    @user_onboarding = options[:user_onboarding]
    @options = options
  end

  def tile_id
    @tile_id ||= id
  end

  def partial
    'client_admin/tiles/manage_tiles/no_cache_single_tile'
  end

  #this method is redundant as to_param is notset for Tile, so it just returns id
  def to_param
    @to_param ||= tile.to_param
  end

  def assembly_required?
    !tile.is_fully_assembled?
  end
  def status
    type
  end

  def status_marker
    # if from_search?
    #   content_tag :div, display_status, class: "status_marker #{display_status}"
    # end
  end

  def display_status
    if completed_class == "completed"
      "completed"
    else
      "unanswered"
    end
  end

  def tile_status
    type
  end

  def completion_status
    tile.is_fully_assembled? ? "finished" : "unfinished"
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

  def show_tile_path(params = {})
    if user_onboarding
      user_onboarding_tile_path(user_onboarding, tile)
    else
      @public_slug ? public_tile_path(@public_slug, tile) : tile_path(tile, params)
    end
  end

  def from_search?
    options[:from_search] == true || options[:from_search] == "true"
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
