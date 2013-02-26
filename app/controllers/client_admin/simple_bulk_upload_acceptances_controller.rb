class ClientAdmin::SimpleBulkUploadAcceptancesController < ApplicationController
  must_be_authorized_to :site_admin

  SCHEMA = %w(employee_id name email location_name gender date_of_birth zip_code)
  UNIQUE_ID = 'employee_id'

  def show
    chopper = S3LineChopperToRedis.new(BULK_UPLOADER_BUCKET, params[:object_key])
    chopper.delay.feed_to_redis

    feeder = UserCreatorFeeder.new(params[:object_key], current_user.demo_id, SCHEMA, UNIQUE_ID)
    feeder.delay.feed

    render :text => 'ok'
  end
end
