class ClientAdmin::BulkUploadPreviewsController < ClientAdminBaseController
  ROWS_TO_PREVIEW = 10

  def show
    chopper = S3LineChopperToRedis.new(BULK_UPLOADER_BUCKET, params[:object_key])
    chopper.feed_to_redis(ROWS_TO_PREVIEW)

    @rows_for_preview = Redis.new(url: ENV['REDISTOGO_URL']).lrange(chopper.redis_preview_queue_key, 0, ROWS_TO_PREVIEW - 1).reverse.map{|line| CSV.parse_line(line)}
  end
end
