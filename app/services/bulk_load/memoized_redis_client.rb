module BulkLoad::MemoizedRedisClient
  def redis
    unless @_redis
      @_redis = Redis.new(url: ENV['REDISTOGO_URL'])
    end

    @_redis
  end
end
