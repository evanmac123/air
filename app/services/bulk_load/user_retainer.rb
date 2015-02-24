class BulkLoad::UserRetainer
  include BulkLoad::MemoizedRedisClient
  include BulkLoad::BulkLoadRedisKeys

  def initialize(object_key)
    @object_key = object_key
  end

  def retain_user(user_id)
    redis.srem(redis_user_ids_to_remove_key, user_id.to_s)
  end

  attr_reader :object_key
end
