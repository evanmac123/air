require 'csv'

class ClientAdmin::BulkUploadPreviewsController < ClientAdminBaseController
  ROWS_TO_PREVIEW = 10

  def show
    #chopper = S3LineChopperToRedis.new(BULK_UPLOADER_BUCKET, params[:object_key])
    #chopper.feed_to_redis(ROWS_TO_PREVIEW)

    #@rows_for_preview = Redis.new(url: ENV['REDISTOGO_URL']).lrange(chopper.redis_preview_queue_key, 0, ROWS_TO_PREVIEW - 1).reverse.map{|line| CSV.parse_line(line)}

    fake_data = <<-END_FAKE_DATA
Dude 1,Pensacola,dude1@example.com
Dude 2,Boston,dude2@example.com
Dude 3,Harrisburg,dude3@example.com
Dude 4,San Rafael,dude4@example.com
Dude 5,Dallas,dude5@example.com
Dude 6,Minneapolis,dude6@example.com
    END_FAKE_DATA
    fake_data = fake_data.split("\n")

    @rows_for_preview = fake_data.reverse.map{|line| CSV.parse_line(line)}
  end
end
