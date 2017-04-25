module CachingConcern

  def set_eager_caches
    if current_user.is_client_admin_in_any_board
      set_client_admin_caches
    end
  end

  private

    def set_client_admin_caches
      set_client_admin_reporting_caches
    end

    def set_client_admin_reporting_caches
      unless cookies[:client_admin_reporting_caches]
        set_cached_cookie(:client_admin_reporting_caches, 5.minutes.from_now)
        BoardMetricsGenerator.delay.set_cache(current_user)
      end
    end

    def set_cached_cookie(key, expiration)
      cookies[key] = { value: "cached", expires: expiration }
    end
end
