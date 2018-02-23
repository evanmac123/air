# frozen_string_literal: true

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

      unless board.redis[:reports_cached].call(:get)
        board.redis[:reports_cached].call(:set, Time.current)
        board.redis[:reports_cached].call(:expire, 12.minutes)
        BoardMetricsGenerator.delay.set_cache(board: board)
      end
    end
end
