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
    current_user.rdb[:copies].sismember(id) > 0
  end

  def show_tile_path
    explore_tile_preview_path(tile)
  end
end
