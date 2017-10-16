class Reporting::BoardHealthReportBuilder
  def self.build_week(board:, to_date:)
    from_date = to_date.beginning_of_week

    BoardHealthReport.where({ demo_id: board.id, from_date: from_date, to_date: to_date, period_cd: BoardHealthReport.periods[:week] }).delete_all

    Reporting::BoardHealthReportBuilder.new(board: board, from_date: from_date, to_date: to_date, period: :week).run
  end

  def self.build_month(board:, to_date:)
    from_date = to_date.beginning_of_month

    BoardHealthReport.where({ demo_id: board.id, from_date: from_date, to_date: to_date, period_cd: BoardHealthReport.periods[:month] }).delete_all

    Reporting::BoardHealthReportBuilder.new(board: board, from_date: from_date, to_date: to_date, period: :month).run
  end

  attr_reader :board, :date_range, :report

  def initialize(board:, from_date:, to_date:, period:)
    @report = board.board_health_reports.new(from_date: from_date, to_date: to_date, period_cd: BoardHealthReport.periods[period])
    @date_range = @report.date_range
  end

  def run
    report.assign_attributes({
      tiles_copied_count: tiles_copied_count,
      user_count: user_count,
      activated_user_percent: activated_user_percent,
      tiles_posted_count: tiles_posted_count,
      tile_completion_average: tile_completion_report[:mean],
      tile_completion_max: tile_completion_report[:max],
      tile_completion_min: tile_completion_report[:min],
      tile_view_average: tile_view_report[:mean],
      tile_view_max: tile_view_report[:max],
      tile_view_min: tile_view_report[:min],
      latest_tile_completion_rate: latest_tile_completion_rate,
      latest_tile_view_rate: latest_tile_view_rate,
      days_since_tile_posted: days_since_tile_posted
    })

    report
  end

  def tiles_copied_count
    report.demo.tiles.where(created_at: date_range).where(creation_source_cd: Tile.creation_sources[:explore_created]).count
  end

  def user_count
    @_user_count ||= report.demo.board_memberships.count
  end

  def activated_user_percent
    if user_count > 0
      report.demo.board_memberships.where("joined_board_at IS NOT NULL").count / user_count.to_f
    else
      0.0
    end
  end

  def tiles_posted_count
    report.demo.tiles.where(activated_at: date_range).count
  end

  def tile_engagement_report
    @_tile_engagement_report ||= report.tile_engagement_report
  end

  def tile_completion_report
    tile_engagement_report[:tile_completion_report]
  end

  def tile_view_report
    tile_engagement_report[:tile_view_report]
  end

  def latest_tile_completion_rate
    report.tiles_digests_for_report.order(:sent_at).last.try(:tile_completion_rate)
  end

  def latest_tile_view_rate
    report.tiles_digests_for_report.order(:sent_at).last.try(:tile_view_rate)
  end

  def days_since_tile_posted
    last_tile_posted = report.demo.tiles.where("activated_at IS NOT NULL").where("activated_at <= ?", report.to_date).order(:activated_at).last

    if last_tile_posted && last_tile_posted.activated_at
      (report.to_date - last_tile_posted.activated_at.to_date).to_i
    end
  end
end
