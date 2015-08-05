class ReorderExplorePageTiles
  attr_reader :tile_ids

  def initialize tile_ids
    @tile_ids = tile_ids
  end
  # TODO: split on methods
  def reorder
    Tile.transaction do
      starting_priority = current_highest_explore_page_priority
      priority = starting_priority + 1

      tile_ids.reverse.each do |tile_id|
        Tile.find(tile_id).update_attribute(:explore_page_priority, priority)
        priority += 1
      end
    end
  end

  protected

  def current_highest_explore_page_priority
    real_priority = Tile.select("MAX(explore_page_priority) AS explore_page_priority").first.explore_page_priority 
    real_priority || -1
  end
end
