require Rails.root.join("config/initializers/redistogo")

$rollout = Rollout.new(Redis.new(url: ENV['REDISTOGO_URL']))

$rollout.define_group(:no_tile_completions) do |user|
  user.tile_completions.count==0
end


