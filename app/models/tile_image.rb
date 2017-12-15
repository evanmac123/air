class TileImage < ActiveRecord::Base
  include Tile::TileImageable

  ROW = 3
  LINES = 6
  PAGINATION_PADDING = (ROW * LINES - 1) # 6 lines

  def self.all_ready
  	where(image_processing: false, thumbnail_processing: false).order{ created_at.desc }
  end

  protected

  def require_images
    true
  end
end
