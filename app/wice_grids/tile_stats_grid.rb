class TileStatsGrid
  attr_reader :tile, :query_type

  def initialize tile, query_type
    @tile = tile
    @query_type = query_type
  end

  def args
    [query, grid_params]
  end

  protected

  def query
    GridQuery::TileActions.new(tile, query_type).query
  end

  def grid_params
    {
      name: 'tile_stats_grid',
      order: 'name',
      order_direction: 'asc',
      per_page: 10,
      enable_export_to_csv: true,
      csv_file_name: "tile_stats_report_#{DateTime.now.strftime("%d_%m_%y")}"
    }
  end
end
