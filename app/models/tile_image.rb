class TileImage < ActiveRecord::Base
  include Concerns::TileImageable

  paginates_per 6
  PAGINATION_PADDING = 5

  def self.all_ready
  	where(image_processing: false, thumbnail_processing: false).order{ created_at.desc }
  end

  protected

  def require_images
    true
  end
end
