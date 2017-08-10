class TileStatsGrid
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
      name: 'tile_stats_grid',
      order: 'tile_completions.created_at',
      order_direction: "DESC",
      custom_order: {
        'tile_completions.created_at' => lambda { |c| "(#{c} IS NULL), #{c}" },
        'tile_completions.answer_index' => lambda { |c| "(#{c} IS NULL), #{c}" }
      },
      per_page: 10,
      csv_file_name: "#{tile.headline.parameterize}-#{DateTime.now.strftime("%d-%m-%y")}"
    }
  end
end
