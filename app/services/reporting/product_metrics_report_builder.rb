class Reporting::ProductMetricsReportBuilder
  def self.build(from_date:, to_date:, period:)
    ProductMetricsReport.where({ from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[period] }).delete_all

    Reporting::ProductMetricsReportBuilder.new(from_date: from_date, to_date: to_date, period: period).run
  end

  def self.build_week(date:)
    build(from_date: date.beginning_of_week, to_date: date.end_of_week, period: :week)
  end

  def self.build_month(date:)
    build(from_date: date.beginning_of_month, to_date: date.end_of_month, period: :month)
  end

  attr_reader :report

  def initialize(from_date:, to_date:, period:)
    @report = ProductMetricsReport.new(from_date: from_date, to_date: to_date, period_cd: ProductMetricsReport.periods[period])
  end

  def run
    report.build
  end
end
