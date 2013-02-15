class S3LineChopperToRedis < S3LineChopper
  include MemoizedRedisClient
  include BulkLoadRedisKeys

  attr_reader :object_key

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
end
