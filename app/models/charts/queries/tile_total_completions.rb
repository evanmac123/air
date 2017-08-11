class Charts::Queries::TileTotalCompletions < Charts::Queries::TileQuery
  def query
    tile.tile_completions.group_by_period(time_unit, "tile_completions.created_at", range: tile_stats_chart_range).count
  end

  def cache_key
    "#{tile.id}:tile_completions_count:#{tile.tile_completions_count}"
  end
end
