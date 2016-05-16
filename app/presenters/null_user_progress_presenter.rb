class NullUserProgressPresenter 
  def initialize(demo)
    @available_tile_count = demo.tiles.active.count
    @completed_tile_count = 0 
    @points = 100 
  end
 
  attr_reader :available_tile_count, :completed_tile_count, :points

  def some_tiles_undone?
    available_tile_count != completed_tile_count  
  end

  def old_browser?
    false
  end
end
