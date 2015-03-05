class TileImage < ActiveRecord::Base
  include Concerns::TileImageable

  protected

  def require_images
    true
  end
end
