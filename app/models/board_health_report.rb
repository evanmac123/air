class BoardHealthReport < ActiveRecord::Base
  belongs_to :demo
  as_enum :period, week: 0, month: 1

  before_save :set_health_score

  def set_health_score
    self.health_score = calculate_health_score.to_i
  end

  def calculate_health_score
    ((tile_completion_average_score + latest_tile_completion_rate_score + activated_user_percent_score + tiles_copied_count) - days_since_tile_posted_score) * 100
  end

  def days_since_tile_posted_score
    days_since_tile_posted.to_f / 30.0
  end

  def tile_completion_average_score
    tile_completion_average.to_f
  end

  def latest_tile_completion_rate_score
    latest_tile_completion_rate.to_f * 0.5
  end

  def activated_user_percent_score
    activated_user_percent.to_f * 0.5
  end

  def copy_count_score
    tiles_copied_count * 0.1
  end

  def tile_engagement_report_cache_key
    "BoardHealthReport:#{demo.id}:tile_engagement_report:#{Date.today}"
  end

  def tile_engagement_report
    Rails.cache.fetch(tile_engagement_report_cache_key) do
      tile_completion_report = demo.tiles_digests.tile_completion_report.stats_base
      tile_view_report = demo.tiles_digests.tile_view_report.stats_base

      {
        tile_completion_report: tile_completion_report,
        tile_view_report: tile_view_report,
      }
    end
  end

  def date_range
    from_date..to_date
  end
end
