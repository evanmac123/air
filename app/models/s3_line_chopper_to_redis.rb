class S3LineChopperToRedis < S3LineChopper
  def feed_to_redis(lines_to_preview)
    count = 0

    chop do |line|
      redis.lpush(redis_preview_queue_key, line) if count < lines_to_preview
      count += 1
    end
  end

  def redis_preview_queue_key
    "bulk_upload:preview:#{@object_key}"
  end

  protected

  def redis
    unless @_redis
      @_redis = Redis.new(url: ENV['REDISTOGO_URL'])
    end

    @_redis
  end
end
