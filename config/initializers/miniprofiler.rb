require 'rack-mini-profiler'

Rack::MiniProfilerRails.initialize!(Rails.application)

Rails.application.middleware.delete(Rack::MiniProfiler)
Rails.application.middleware.insert_after(Rack::Deflater, Rack::MiniProfiler)
uri = URI.parse(ENV["REDISTOGO_URL"] ||"redis://127.0.0.1:6379/0")
Rack::MiniProfiler.config.storage_options = { :host => uri.host, :port => uri.port,    :password => uri.password }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
PROFILABLE_USERS = ENV['PROFILABLE_USERS'].try(:split, ",") || []
