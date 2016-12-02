class TileFeature < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :rank, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { active.order(:rank) }

  def dispatch_redis_updates(redis_params)
    redis_params.each { |redis_key, value|
      self.send("#{redis_key}=", value) if value
    }
  end

  def tile_ids=(tile_ids)
    tile_ids = tile_ids.gsub(/\s+/, "").split(",").select { |id| id.to_i != 0 }
    eligible_tiles = Tile.copyable.where(id: tile_ids).pluck(:id)
    tile_ids = tile_ids.select { |id| eligible_tiles.include?(id.to_i) }

    rdb[:tile_ids].set(tile_ids.join(","))
  end

  def tile_ids
    ids = rdb[:tile_ids].get
    ids.split(",") if ids
  end

  def tile_ids_formatted
    rdb[:tile_ids].get
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
    # TODO: Benchmark methods for retrieving AR objects in given order
    grouped_tiles = tiles.where(id: tile_ids).group_by(&:id)

    tile_ids.map { |id| grouped_tiles[id.to_i].try(:first) }
  end
end
