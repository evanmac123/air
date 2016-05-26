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
  attr_reader :tile, :type

  def initialize object,template, options
    super
  end

  presents :tile

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


  #def has_activation_dates?
    #true
  #end

  def has_tile_buttons?
    true
  end

  def activation_dates
    h.content_tag :div, timestamp, class: "activation_dates"
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

  def has_menu?
    show_admin_buttons? && (type? :draft, :active, :archive)
  end

  def has_tile_stats?
    show_admin_buttons? && (type? :active, :archive)
  end

  def shows_creator?
    type? :user_submitted
  end

  def show_tile_path
    if viewing_as_regular_user?
      suggested_tile_path(self)
    else
      client_admin_tile_path(self)
    end
  end

  def timestamp
    #@timestamp ||= footer_timestamp
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

  def tile_id
    @tile_id ||= id
  end

  def tile_position
   @tile.position || 0
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
      thumbnail,
      type,
      tile_id,
      headline,
      tile_completions_count,
      total_views,
      unique_views,
      @as_admin,
      @is_ie
    ].join('-')
  end


end
