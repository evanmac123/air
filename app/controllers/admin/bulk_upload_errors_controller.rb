class Admin::BulkUploadErrorsController < AdminBaseController
  include BulkLoad::MemoizedRedisClient
  include BulkLoad::BulkLoadRedisKeys

  def show
    @errors = redis.lrange(redis_failed_load_queue_key, 0, -1)
  end

  def object_key
    params[:object_key]
  end
end
