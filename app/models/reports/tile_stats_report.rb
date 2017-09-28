class Reports::TileStatsReport
  include Rails.application.routes.url_helpers

  attr_reader :tile

  def initialize(tile_id:)
    @tile = Tile.find(tile_id)
  end

  def data
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
      chartId: "tileActivityChart",
      chartSeriesNames: ["People Viewed", "People Completed"],
      chartTemplate: "loginActivityTilesDigestTemplate",
      tileMessageOptionsForScope: TileUserNotification.options_for_scope_cd,
      tileMessageOptionsForAnswers: TileUserNotification.options_for_answers(tile: tile),
      defaultNotificationRecipientCount: default_notification_recipient_count,
      tileUserNotifications: tile_user_notifications_for_report,
      tileActivitySeries: tile_activity_series,
      linkClickStats: link_click_stats,
      hasLinkTracking: has_link_tracking?
    }
  end

  private

    def tile_activity_series
      chart = Charts::TileViewsAndCompletionsChart.new({ tile: tile }).attributes(["unique_views", "total_completions"])
      hide_second_series_by_default!(chart)
      chart
    end

    def hide_second_series_by_default!(chart)
      chart[:series][1][:visible] = false
    end

    def tile_user_notifications_for_report
      tile.tile_user_notifications.map do |notification|
        notification.decorate_for_tile_stats_table
      end
    end

    def default_notification_recipient_count
      TileUserNotification.default_recipient_count(tile: tile)
    end

    def link_click_stats
      @_link_click_stats ||= tile.link_click_stats
    end

    def has_link_tracking?
      tile.has_link_tracking? && link_click_stats.length > 0
    end
end
