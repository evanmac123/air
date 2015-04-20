class BulkLoad::S3CensusChopper < BulkLoad::S3LineChopper
  def initialize(bucket_name, object_key, unique_id_index)
    super(bucket_name, object_key)
    @unique_id_index = unique_id_index
  end

  def feed_to_redis(lines_to_preview = nil)
    @count = 0

    chop do |line|
      redis.lpush(redis_preview_queue_key, line) if lines_to_preview && @count < lines_to_preview
      redis.lpush(redis_load_queue_key, line)
      redis.sadd(redis_unique_ids_key, CSV.parse_line(line)[@unique_id_index])

      @count += 1
      redis.set(redis_lines_completed_key, @count)
    end

    redis.set(redis_all_lines_chopped_key, "done")
  end
end
