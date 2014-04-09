module TilesHelper
  def tile_class(tile)
    (@show_completed_tiles == true) || current_user.tile_completions.where(tile_id: tile.id).exists? ? 'completed' : 'not_completed'
  end

  def is_url? str
    (!str.nil? && \
      str.include?(".") && \
      !str.include?(" ") && \
      str[/[a-zA-Z]+/] && \
      !str[/\.{2,}/] && \
      str[/^[\w].*[^.]$/]) ? true : false
  end

  def make_url str
    (str.start_with?("http://", "https://") ? "" : "http://") + str
  end
end
