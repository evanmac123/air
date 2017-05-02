task update_tile_copy_count: :environment do
  Tile.explore.each { |t| t.update_attribute(:copy_count, t.rdb[:copy_count].get.to_i); t.rdb[:copy_count].del }
end
