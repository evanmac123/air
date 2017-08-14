class Reports::TileStatsReport
  include Rails.application.routes.url_helpers

  attr_reader :tile

  def initialize(tile_id:)
    @tile = Tile.find(tile_id)
  end

  def data
    Rails.cache.fetch(report_cache_key) do
      {
        id: tile.id,
        datePosted: tile.activated_at,
        dateSent: tile.sent_at,
        headline: tile.headline,
        question: tile.question,
        totalViews: tile.total_viewings_count,
        uniqueViews: tile.unique_viewings_count,
        totalCompletions: tile.tile_completions_count,
        surveyChart: tile.survey_chart,
        activityGridUpdatePath: client_admin_tile_tile_stats_grids_path(tile),
        activityGridUpdatesPollingPath: new_completions_count_client_admin_tile_tile_stats_grids_path(tile),
        tileActivityGridTypes: GridQuery::TileActions::GRID_TYPES.invert,
        tileActivitySeries: tile_activity_series,
        chartId: "tileActivityChart",
        chartSeriesNames: ["People Viewed", "People Completed"],
        chartTemplate: "loginActivityTilesDigestTemplate"
      }
    end
  end

  def tile_activity_series
    chart = Charts::TileViewsAndCompletionsChart.new({ tile: tile }).attributes(["unique_views", "total_completions"])

    hide_second_series_by_default!(chart)
    chart
  end

  def hide_second_series_by_default!(chart)
    chart[:series][1][:visible] = false
  end

  def report_cache_key
    "#{tile.cache_key}::tile_completions:#{tile.tile_completions_count}::tile_views:#{tile.unique_viewings_count}"
  end
end
