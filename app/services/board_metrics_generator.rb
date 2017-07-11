class BoardMetricsGenerator
  class << self
    def set_cache(board:)
      BoardMetricsGenerator.new(board: board).update_metrics_caches_for_board
    end
  end

  attr_reader :board

  def initialize(board:)
    @board = board
  end

  def update_metrics_caches_for_board
    puts "Updating metrics cache for Board #{board.id}."

    [:week, :month, :quarter].each do |interval|
      Charts::Queries::BoardUniqueTileViews.new(board, interval).set_cached_query
      Charts::Queries::BoardUniqueTileCompletions.new(board, interval).set_cached_query
      Charts::Queries::BoardUniqueLoginActivity.new(board, interval).set_cached_query
      Charts::Queries::BoardTotalTileViews.new(board, interval).set_cached_query
      Charts::Queries::BoardTilesPosted.new(board, interval).set_cached_query
      Charts::Queries::BoardDigestsSent.new(board, interval).set_cached_query
    end
  end
end
