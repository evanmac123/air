class SingleExploreTilePresenter < BasePresenter

  delegate  :id,
            :thumbnail,
            :headline,
            to: :tile

  attr_reader :tile, :tiles_grouped_ids, :section

  presents :tile

  def initialize(object, template, options)
    super
    @format =  options[:format]||:html
    @section = options[:section]
  end

  def copied?
    if current_user.is_a?(GuestUser) || current_user.end_user?
      false
    else
      $redis.sismember("Demo:#{current_user.try(:demo_id)}:copies", id)
    end
  end

  def show_tile_path
    explore_tile_preview_path(tile)
  end

  # TODO: refactor inline style and mange cache for guests
  def explore_tile_button_display
    if current_user.is_a?(GuestUser) || current_user.end_user?
      "none"
    end
  end

  def cache_key
    @cache_key ||= [
      self.class,
      thumbnail,
      id,
      headline,
      copied?,
      @is_ie,
      section
    ].join('-')
  end
end
