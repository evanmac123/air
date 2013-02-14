class S3LineChopperToRedis < S3LineChopper
  include MemoizedRedisClient

  def feed_to_redis(lines_to_preview)
    count = 0

    chop do |line|
      redis.lpush(redis_preview_queue_key, line) if count < lines_to_preview
      redis.lpush(redis_load_queue_key, line)

      count += 1
      redis.set(redis_lines_completed_key, count)
    end

    redis.set(redis_all_lines_chopped_key, "done")
  end

  def redis_preview_queue_key
    "bulk_upload:preview:#{@object_key}"
  end

  def redis_load_queue_key
    "bulk_upload:load:#{@object_key}"
  end

  def redis_lines_completed_key
    "bulk_upload:lines_completed:#{@object_key}"
  end

  def redis_all_lines_chopped_key
    "bulk_upload:all_lines_chopped:#{@object_key}"
  end
end
