class TileImage < ActiveRecord::Base
  include Concerns::TileImageable

  ROW = 3
  paginates_per (ROW * 6) # 6 lines
  PAGINATION_PADDING = (ROW * 6 - 1) # 6 lines

  def self.all_ready
  	where(image_processing: false, thumbnail_processing: false).order{ created_at.desc }
  end

  protected

  def require_images
    true
  end
end
