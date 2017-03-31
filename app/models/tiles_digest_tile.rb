class TilesDigestTile < ActiveRecord::Base
  belongs_to :tile
  belongs_to :tiles_digest
end
