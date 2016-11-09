class RecommendedTile < ActiveRecord::Base
  belongs_to :tile
  validate :tile, presence: true
  validate :tile_id, uniqueness: true
end
