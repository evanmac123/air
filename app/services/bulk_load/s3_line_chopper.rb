class BulkLoad::S3LineChopper
  include BulkLoad::MemoizedRedisClient
  include BulkLoad::BulkLoadRedisKeys

  attr_reader :object_key
  attr_reader :count

  def initialize(bucket_name, object_key, unique_id_index)
    @bucket_name = bucket_name
    @object_key = object_key
    @unique_id_index = unique_id_index
  end

  def chop(&block)
    buffer = ""
    s3.buckets[@bucket_name].objects[@object_key].read do |chunk|
      buffer += chunk
      
      buffer.lines.each do |line|
        if line =~ /\n$/
          block.call(line)
          buffer = ""
        else
          buffer = line
        end
      end
    end
  end

  def feed_to_redis(lines_to_preview = nil)
    @count = 0

    chop do |line|
      redis.lpush(redis_preview_queue_key, line) if lines_to_preview && @count < lines_to_preview
      redis.lpush(redis_load_queue_key, line)
      redis.lpush(redis_unique_id_queue_key, CSV.parse_line(line)[@unique_id_index])

      @count += 1
      redis.set(redis_lines_completed_key, @count)
    end

    redis.set(redis_all_lines_chopped_key, "done")
  end
 
  private

  def s3
    unless @_s3
      @_s3 = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    end

    @_s3
  end
end
