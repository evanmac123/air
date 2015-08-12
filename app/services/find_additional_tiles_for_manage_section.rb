class FindAdditionalTilesForManageSection
  attr_reader :status_name, :presented_ids, :tile_demo_id

  def initialize(status_name, presented_ids, tile_demo_id)
    @status_name = status_name
    @presented_ids = presented_ids 
    @tile_demo_id = tile_demo_id
  end
  # TODO: split to methods
  def find
    ids = presented_ids || []
    needs_tiles = if status_name == Tile::ACTIVE || status_name == Tile::DRAFT
                    0
                  else 
                    ids.count >= 4 ? 0 : (4 - ids.count)
                  end
    return [] if needs_tiles == 0


    Tile.where(demo_id: tile_demo_id)
        .where(status: status_name)
        .where{id.not_in ids}
        .ordered_by_position.first(needs_tiles)
  end
end
