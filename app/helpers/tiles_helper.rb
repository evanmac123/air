module TilesHelper
  def tile_class(tile)
    (@show_completed_tiles == true) || current_user.tile_completions.where(tile_id: tile.id).exists? ? 'completed' : 'not_completed'
  end

  # nil is definitely not a url
  # with dots
  # without spaces
  # have at least one letter
  # no two dots together
  # starts with letter, ends with not dot
  def is_url? str
    !str.nil? && \
    str.include?(".") && \
    !str.include?(" ") && \
    str[/[a-zA-Z]+/] && \
    !str[/\.{2,}/] && \
    str[/^[\w].*[^.]$/]
  end

  def make_full_url str
    if is_url? str
      (str.start_with?("http://", "https://") ? "" : "http://") + str
    else
      str
    end
  end

  # need this function to set height of image place in ie8 while image is loading
  def tile_image_height tile
    height = tile.image.height.to_f
    width = tile.image.width.to_f
    full_width = 600.0 # px for full size tile
    ( height * full_width / width ).to_i
  end
end
