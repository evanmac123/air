class BoardStatsGrid
  attr_reader :board, :query_type

  def initialize board, query_type = nil
    @board = board
    @query_type = set_query_type(query_type)
  end

  def args
    [query, grid_params]
  end

  protected

  def set_query_type(query_type)
    if query_type.present?
      query_type
    else
      GridQuery::BoardActions::GRID_TYPES.keys.first
    end
  end

  def query
    GridQuery::BoardActions.new(board, query_type).query
  end

  def grid_params
    {
      name: 'board_stats_grid',
      order: 'board_tile_viewings.updated_at',
      order_direction: 'desc',
      per_page: 40,
      enable_export_to_csv: true,
      csv_file_name: "board_stats_report_#{DateTime.now.strftime("%d_%m_%y")}"
    }
  end
end
