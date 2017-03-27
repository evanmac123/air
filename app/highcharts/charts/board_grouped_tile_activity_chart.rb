class Charts::BoardGroupedTileActivityChart < ChartBase
  def unique_tile_views
    Query::BoardUniqueTileViews.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def total_tile_views
    Query::BoardTotalTileViews.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def total_tile_interactions
    Query::BoardUniqueTileCompletions.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end
end
