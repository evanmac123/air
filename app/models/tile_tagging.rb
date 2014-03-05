class TileTagging < ActiveRecord::Base
  belongs_to :tile
  belongs_to :tile_tag
end
