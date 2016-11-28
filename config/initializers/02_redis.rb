case Rails.env
when 'production', 'staging', "production_local"
  $redis = Redis.new(url: ENV['REDISTOGO_URL'])
when 'test',  'development'
  $redis = Redis.new(host: 'localhost', port: 6379)
end

class Redis
  class << self
    def non_cache_keys
      $redis.scan(0, { match: "[^cache]*" })[1]
    end
  end
end

Nest.class_eval do
  def initialize(key, redis = $redis)
    super(key.to_param)
    @redis = redis
  end

  def [](key)
    self.class.new("#{self}:#{key.to_param}", @redis)
  end
end

ActiveRecord::Base.class_eval do
  def rdb
    Nest.new(self.class.name)[id]
  end

  def self.rdb
    Nest.new(name)
  end
end
