class Charts::BoardTotalTileViewsChart < Charts::ChartBase
  def primary_data
    Charts::Queries::BoardTotalTileViews.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end
end
