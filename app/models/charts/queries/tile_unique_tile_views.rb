class Charts::Queries::TileUniqueTileViews < Charts::Queries::TileQuery
  def query
    tile.tile_viewings.group_by_period(time_unit, "tile_viewings.created_at", range: tile_stats_chart_range).count
  end

  def cache_key
    "#{tile.id}:unique_tile_views:#{tile.unique_viewings_count}"
  end
end
