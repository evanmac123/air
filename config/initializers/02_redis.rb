case Rails.env
when 'production', 'staging', "production_local"
  $redis = Redis.new(url: ENV['REDISTOGO_URL'])
when 'test',  'development'
  $redis = Redis.new(:host => 'localhost', :port => 6379)
end

class Redis
  class << self
    def non_cache_keys
      $redis.scan(0, { match: "[^cache]*" })[1]
    end
  end
end
