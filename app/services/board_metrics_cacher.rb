# frozen_string_literal: true

class BoardMetricsCacher
  def self.call(board:)
    BoardMetricsCacher.new(board).cache
  end

  attr_reader :board, :redis_metrics_key

  def initialize(board)
    @board = board
    @redis_metrics_key = board.redis[:reports_cached]
  end

  def cache
    unless redis_metrics_key.call(:get)
      redis_metrics_key.call(:set, Time.current)
      redis_metrics_key.call(:expire, 12.minutes)
      BoardMetricsGeneratorJob.perform_later(board: board)
    end
  end
end
