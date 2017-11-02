desc "Organization statistics posted to Redis"
task organization_stats_in_redis: :environment do
  Organization.paid.each do |org|
    puts "Calculating stats for #{org.name}..."
    total_tile_viewings = org.boards.joins(:tile_viewings).count
    total_tiles_created = org.boards.joins(:tiles).count

    org.rdb[:total_tile_viewings].set(total_tile_viewings)
    org.rdb[:total_tiles_created].set(total_tiles_created)
  end
end
