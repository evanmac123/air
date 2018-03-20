# frozen_string_literal: true

module CachingConcern
  def set_eager_caches
    if current_user && current_user.is_a?(User)
      if current_user.is_client_admin || current_user.is_site_admin
        set_client_admin_reporting_caches
      end
    end
  end

  private

    def set_client_admin_reporting_caches
      BoardMetricsCacher.call(board: current_board)
    end
end
