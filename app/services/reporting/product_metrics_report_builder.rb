class Reporting::ProductMetricsReportBuilder
  def self.build_week(to_date:)
    to_date = to_date.end_of_week
    from_date = to_date.beginning_of_week

    ProductMetricsReport.where({ from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[:week] }).delete_all

    Reporting::ProductMetricsReportBuilder.new(from_date: from_date, to_date: to_date, period: :week).run
  end

  def self.build_month(to_date:)
    to_date = to_date.end_of_month
    from_date = to_date.beginning_of_month

    ProductMetricsReport.where({ from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[:month] }).delete_all

    Reporting::ProductMetricsReportBuilder.new(from_date: from_date, to_date: to_date, period: :month).run
  end

  attr_reader :report

  def initialize(from_date:, to_date:, period:)
    @report = ProductMetricsReport.new(from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[period])
  end

  def run
    report.build
  end
end
