class Charts::BoardTilesCreatedChart < ChartBase
  def primary_data
    Query::BoardTilesCreated.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def client_admin_created
    Query::BoardTilesCreated.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date, Tile.client_admin_created).to_a
  end

  def explore_created
    Query::BoardTilesCreated.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date, Tile.explore_created).to_a
  end

  def suggestion_box_created
    Query::BoardTilesCreated.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date, Tile.suggestion_box_created).to_a
  end

  def cumulative_data
    super(primary_data)
  end
end
