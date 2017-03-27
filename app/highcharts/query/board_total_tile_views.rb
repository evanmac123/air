class Query::BoardTotalTileViews < Query::BoardQuery
  def query
    board.tile_viewings.group_by_period(time_unit, "tile_viewings.created_at").sum(:views)
  end

  def cache_key
    "#{board.id}:total_tile_views:#{time_unit}"
  end
end
