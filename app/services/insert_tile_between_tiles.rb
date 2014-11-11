class InsertTileBetweenTiles
  def initialize left_tile_id, tile_id, right_tile_id, status = nil
    @left_tile = Tile.where(id: left_tile_id).first
    @tile = Tile.where(id: tile_id).first
    @right_tile = Tile.where(id: right_tile_id).first
    @status = status if Tile::STATUS.include?(status)
  end

  def insert!
    return if tile_is_already_on_this_place
    set_new_status
    return if first_and_only_in_section
    search_for_right_tile # if right tile was not displayed on manage page(out of 8 displayed)
    Tile.transaction do
      set_tile_position
      update_tile_positions_to_the_left
    end
  end

  protected

  def tile_is_already_on_this_place
    if  (@left_tile.present? && @left_tile == @tile.left_tile) ||
        (@right_tile.present? && @right_tile == @tile.right_tile)
      if @status.present? && @status != @tile.status
        false
      else
        true
      end
    else
      false
    end
  end

  def set_new_status
    @tile.status = @status if @status.present? && @status != @tile.status
  end

  def first_and_only_in_section
    unless @right_tile || @left_tile
      @tile.position = 0
      @tile.save
    end
  end

  def search_for_right_tile
    unless @right_tile
      left_demo = @left_tile.demo
      left_status = @left_tile.status
      left_position = @left_tile.position
      @right_tile = left_demo.tiles.where{
        (status == left_status) & 
        (position < left_position)
      }.ordered_by_position.first
    end
  end

  def set_tile_position
    if @right_tile
      @tile.position = @right_tile.position.to_i + 1
    else
      @tile.position = @left_tile.position.to_i
    end
    @tile.save
  end

  def update_tile_positions_to_the_left
    tile_demo = @tile.demo
    tile_status = @tile.status
    tile_position = @tile.position
    tile_id = @tile.id
    Tile.where{ (demo == tile_demo) & 
                (status == tile_status) & 
                (position >= tile_position) &
                (id != tile_id)
    }.order("position ASC").each_with_index do |tile, index|
      tile.update_attribute :position, (tile_position + index + 1)
    end
  end
end
