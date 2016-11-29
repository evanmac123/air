class TileFeature < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :rank, uniqueness: true

  def tile_ids(starting_position = 0, ending_position = 5)
    rdb[:tile_ids].zrange(starting_position, ending_position)
  end

  def add_tile(position, id)
    rdb[:tile_ids].zadd(position, id)
  end

  def custom_icon_url
    rdb[:custom_icon_url].get
  end

  def custom_icon_url=(url)
    rdb[:custom_icon_url].set(url)
  end

  def text_color
    rdb[:text_color].get
  end

  def text_color=(color)
    rdb[:text_color].set(color)
  end

  def header_copy
    rdb[:header_copy].get
  end

  def header_copy=(copy)
    rdb[:header_copy].set(copy)
  end

  def background_color
    rdb[:background_color].get
  end

  def background_color=(color)
    rdb[:background_color].set(color)
  end

  def get_tiles(tiles)
    tiles.where(id: tile_ids)
  end
end
