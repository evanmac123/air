task update_tiles_for_planning: :environment do
  Tile.draft.update_all(status: Tile::PLAN)

  Demo.all.each { |demo|
    cutoff_time = demo.tile_digest_email_sent_at
    tiles = demo.tiles.active

    draft_tiles = tiles.where("activated_at > ?", cutoff_time)

    draft_tiles.update_all(status: Tile::DRAFT)
  }
end
