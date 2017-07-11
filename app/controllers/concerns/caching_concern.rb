module CachingConcern

  def set_eager_caches
    if current_user && current_user.is_a?(User)
      if current_user.is_client_admin || current_user.is_site_admin
        set_client_admin_caches
      end
    end
  end

  private

    def set_client_admin_caches
      set_client_admin_reporting_caches
    end

    def set_client_admin_reporting_caches
      board = current_user.demo

      unless board.rdb[:reports_cached].get
        board.rdb[:reports_cached].set(Time.now)
        board.rdb[:reports_cached].expire(12.minutes)
        BoardMetricsGenerator.delay.set_cache(board: board)
      end
    end
end
