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
    $redis.sismember("Demo:#{current_user.demo_id}:copies", id)
  end

  def show_tile_path
    explore_tile_preview_path(tile)
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
