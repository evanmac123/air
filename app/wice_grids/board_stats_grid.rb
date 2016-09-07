class BoardStatsGrid
  attr_reader :tile, :query_type, :answer_filter

  def initialize tile, query_type = nil, answer_filter = nil
    @tile = tile
    @query_type = set_query_type(query_type)
    @answer_filter = answer_filter.present? ? answer_filter : nil
  end

  def args
    [query, grid_params]
  end

  protected

  def set_query_type(query_type)
    if query_type.present?
      query_type
    else
      GridQuery::TileActions::GRID_TYPES.keys.first
    end
  end

  def query
    GridQuery::TileActions.new(tile, query_type, answer_filter).query
  end

  def grid_params
    {
      name: 'board_stats_grid',
      order: 'name',
      order_direction: 'asc',
      per_page: 10,
      enable_export_to_csv: true,
      csv_file_name: "board_stats_report_#{DateTime.now.strftime("%d_%m_%y")}"
    }
  end
end
