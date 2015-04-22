class Admin::BulkUploadProgressesController < AdminBaseController
  include BulkLoad::MemoizedRedisClient
  include BulkLoad::BulkLoadRedisKeys

  def show
    baseline_time = Chronic.parse(params[:baseline_time])
    demo = Demo.find(params[:demo_id])

    @load_queue_length = redis.llen(redis_load_queue_key)
    @failed_load_queue_length = redis.llen(redis_failed_load_queue_key)

    @updated_user_count = demo.users.updated_since(baseline_time).count
    @not_updated_user_count = demo.users.not_updated_since(baseline_time).count

    @never_attempted_dj_count = Delayed::Job.where(attempts: 0).count

    @object_key = object_key
  end

  def object_key
    params[:object_key]
  end
end
