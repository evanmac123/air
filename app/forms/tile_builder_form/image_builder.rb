class TileBuilderForm::ImageBuilder

  def initialize image, image_container, old_image_container, no_image, image_from_library
    @image = image
    @image_container = image_container.present? ? image_container.to_i : nil
    @old_image_container = old_image_container.present? ? old_image_container.to_i : nil
    @no_image = no_image
    @image_from_library = image_from_library.present? ? image_from_library.to_i : nil
  end

  def find_image_container
    @container_id ||= set_container_id
  end

  def find_image
    if find_image_container
      ImageContainer.find(find_image_container).image
    elsif @image_from_library
      find_image_from_library.image
    else
      @image
    end
  end

  def find_image_from_library_id
    @image_from_library
  end

  def find_image_from_library
    TileImage.find(@image_from_library)
  end

  def delete_old_image_container(tile_saved)
    if @old_image_container &&
      (tile_saved || !@image_container) 

      ImageContainer.find(@old_image_container).destroy
    end
  end

  def set_tile_image
    if @image.present?
      @image
    elsif @no_image
      nil
    elsif @image_container
      ImageContainer.find(@image_container).image
    elsif @image_from_library
      :image_from_library
    else 
      :leave_old
    end
  end

  protected

  def set_container_id
    if @image_container && !@no_image
      ImageContainer.find(@image_container).id
    elsif @no_image
      nil
    elsif @image
      ImageContainer.tile_image(@image).id
    else
      nil
    end
  end
end