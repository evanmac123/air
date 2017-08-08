class Reports::TileStatsReport
  include Rails.application.routes.url_helpers

  attr_reader :tile

  def initialize(tile_id:)
    @tile = Tile.find(tile_id)
  end

  def data
    {
      id: tile.id,
      headline: tile.headline,
      question: tile.question,
      totalViews: tile.total_viewings_count,
      uniqueViews: tile.unique_viewings_count,
      totalCompletions: tile.tile_completions_count,
      surveyChart: tile.survey_chart,
      activityGridUpdatePath: client_admin_tile_tile_stats_grids_path(tile),
      activityGridUpdatesPollingPath: new_completions_count_client_admin_tile_tile_stats_grids_path(tile),
      tileActivityGridTypes: GridQuery::TileActions::GRID_TYPES.invert
    }
  end
end
