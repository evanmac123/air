module ApplicationPerformanceConcern
  def set_scout_context
    if current_user.is_a?(User)
      if current_user.is_site_admin?
        ScoutApm::Context.add(site_admin: true)
      elsif current_user.is_client_admin?
        ScoutApm::Context.add(client_admin: true)
      else
        ScoutApm::Context.add(end_user: true)
      end
    else
      ScoutApm::Context.add(not_logged_in: true)
    end
  end

  def enable_miniprofiler
    #NOTE on by default in development
    if Rails.env.production_local? || (current_user && Rails.env.production? && PROFILABLE_USERS.include?(current_user.email))
      Rack::MiniProfiler.authorize_request
    end
  end

  def profiler_step(name, &block)
    Rack::MiniProfiler.step(name) do
      yield
    end
  end
end
