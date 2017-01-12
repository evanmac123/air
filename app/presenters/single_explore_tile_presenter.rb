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

  def user_type
    if current_user.end_user? || current_user.is_a?(GuestUser)
      "explore_guest"
    else
      "explore_user"
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
      section,
      user_type
    ].join('-')
  end
end
