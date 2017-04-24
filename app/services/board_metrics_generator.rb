class BoardMetricsGenerator
  class << self
    def update_metrics_caches_for_users_boards(user)
      if user.is_site_admin
        boards = [user.demo]
      else
        boards = user.demos.select(:id)
      end

      BoardMetricsGenerator.new(boards).update_metrics_caches
    end
  end

  attr_reader :boards

  def initialize(boards)
    @boards = boards
  end

  def update_metrics_caches
    boards.each do |board|
      update_metrics_caches_for_board(board)
    end
  end

  def update_metrics_caches_for_board(board)
    puts "Updating metrics cache for Board #{board.id}."

    [:week, :month, :quarter].each do |interval|
      Charts::Queries::BoardUniqueTileViews.new(board, interval).set_cached_query
      Charts::Queries::BoardUniqueTileCompletions.new(board, interval).set_cached_query
      Charts::Queries::BoardUniqueLoginActivity.new(board, interval).set_cached_query
      Charts::Queries::BoardTotalTileViews.new(board, interval).set_cached_query
      Charts::Queries::BoardTilesPosted.new(board, interval).set_cached_query
      Charts::Queries::BoardDigestsSent.new(board, interval).set_cached_query
    end

    board.rdb[:reports_cached_at].set(Time.now)
  end
end
