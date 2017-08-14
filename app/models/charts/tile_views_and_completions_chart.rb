class Charts::TileViewsAndCompletionsChart < Charts::ChartBase
  def unique_views
    Charts::Queries::TileUniqueTileViews.new(tile_from_params).cached_query
  end

  def total_completions
    Charts::Queries::TileTotalCompletions.new(tile_from_params).cached_query
  end
end
