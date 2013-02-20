class UserCreatorFeeder
  include MemoizedRedisClient
  include BulkLoadRedisKeys

  attr_reader :object_key

  def initialize(object_key, demo_id, schema, unique_id_field)
    @object_key = object_key
    @demo_id = demo_id
    @schema = schema
    @unique_id_field = unique_id_field
    @line_index = 0
  end

  def feed
    while !done?
      line = redis.rpop(redis_load_queue_key)
      @line_index += 1

      user = user_creator.create_user(line)

      if user.invalid?
        redis.lpush(redis_failed_load_queue_key, line_error_message(user))
      end
    end
  end

  def done?
    redis.llen(redis_load_queue_key) == 0
  end

  protected

  def user_creator
    unless @_user_creator
      @_user_creator = UserCreatorFromCsv.new(@demo_id, @schema, @unique_id_field)
    end

    @_user_creator
  end

  def line_error_message(user)
    "Line #{@line_index}: #{user.errors.full_messages.to_sentence}"
  end
end
