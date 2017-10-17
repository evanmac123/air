class BoardHealthReport < ActiveRecord::Base
  belongs_to :demo
  as_enum :period, week: 0, month: 1

  before_save :set_health_score

  def set_health_score
    self.health_score = calculate_health_score.to_i

    if self.week?
      demo.update_attributes(current_health_score: health_score)
    end
  end

  def calculate_health_score
    (tile_completion_average_score + latest_tile_completion_rate_score + activated_user_percent_score + copy_count_score + days_since_tile_posted_score) * 100
  end

  def days_since_tile_posted_score
    1 - (days_since_tile_posted.to_f / 15.0)
  end

  def tile_completion_average_score
    tile_completion_average.to_f
  end

  def latest_tile_completion_rate_score
    latest_tile_completion_rate.to_f
  end

  def activated_user_percent_score
    activated_user_percent.to_f * 0.25
  end

  def copy_count_score
    if tiles_copied_count.to_i > 0
      0.50
    else
      0
    end
  end

  def tile_engagement_report_cache_key
    "BoardHealthReport:#{demo.id}:tile_engagement_report:#{Date.today}"
  end

  def tile_engagement_report
    tile_completion_report = tiles_digests_for_report.tile_completion_report.stats_base
    tile_view_report = tiles_digests_for_report.tile_view_report.stats_base

    {
      tile_completion_report: tile_completion_report,
      tile_view_report: tile_view_report,
    }
  end

  def tiles_digests_for_report
    demo.tiles_digests.where("sent_at <= ?", (to_date - 1.week).end_of_day)
  end

  def date_range
    from_date..to_date
  end
end
