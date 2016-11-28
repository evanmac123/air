class TileFeature < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :rank, uniqueness: true

  def tile_ids
    rdb[:tile_ids].zmembers
  end

  def add_tiles(ids_with_order)
    rdb[:tile_ids].zadd(ids_with_order)
  end
end
