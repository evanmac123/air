module MiniprofilerHelper
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
