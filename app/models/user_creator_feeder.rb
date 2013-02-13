class UserCreatorFeeder
  include MemoizedRedisClient

  def initialize(queue_key, demo_id, schema)
    @queue_key = queue_key
    @demo_id = demo_id
    @schema = schema
  end

  def feed
    while !done?
      line = redis.rpop(@queue_key)
      user_creator.create_user(line)
    end
  end

  def done?
    redis.llen(@queue_key) == 0
  end

  protected

  def user_creator
    unless @_user_creator
      @_user_creator = UserCreatorFromCsv.new(@demo_id, @schema)
    end

    @_user_creator
  end
end
