class RecommendedTile < ActiveRecord::Base
  belongs_to :tile
  validate :tile, presence: true
end
