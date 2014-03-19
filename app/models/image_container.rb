class ImageContainer < ActiveRecord::Base
  has_attached_file :image, {:bucket => S3_TILE_BUCKET}.merge(TILE_IMAGE_OPTIONS)

  def self.tile_image image
    if image
      ic = self.new
      ic.image = image
      ic.save
      ic
    else
      nil
    end
  end
end
