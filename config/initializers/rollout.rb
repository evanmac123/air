require Rails.root.join("config/initializers/redistogo")

$rollout = Rollout.new(Redis.new(url: ENV['REDISTOGO_URL']))

