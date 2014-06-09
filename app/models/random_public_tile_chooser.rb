class RandomPublicTileChooser
  def choose_tile
    tiles.offset(rand(tiles.length)).limit(1).first
  end

  protected

  def tiles
    @tiles ||= Tile.viewable_in_public.order("id ASC")
  end
end
