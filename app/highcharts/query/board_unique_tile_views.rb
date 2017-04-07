class Query::BoardUniqueTileViews < Query::BoardQuery
  def query
    board.tile_viewings.group_by_period(time_unit, "tile_viewings.created_at").count
  end

  def cache_key
    "#{board.id}:unique_tile_views:#{time_unit}"
  end
end
