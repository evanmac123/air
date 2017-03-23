class TilesDigestTile < ActiveRecord::Base
  belongs_to :tiles_digest
  belongs_to :tile
end
