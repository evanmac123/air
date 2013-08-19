class SampleTile < Tile
  include SampleTileBehavior

  def image_filename
    "sample_tile_image.png"  
  end

  def thumbnail_filename
    "sample_tile_thumbnail.png"  
  end

  def thumbnail_hover_filename
    "sample_tile_hover_thumbnail.png"  
  end
end
