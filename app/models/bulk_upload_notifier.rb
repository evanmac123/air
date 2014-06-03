class BulkUploadNotifier
  def initialize(uploading_user, bucket, key)
    @uploading_user = uploading_user
    @bucket = bucket
    @key = key
  end

  def notify_us_of_upload
    BulkUploadNotificationMailer.delay_mail(:file_uploaded, @uploading_user.name, @uploading_user.email, @uploading_user.demo.name, @uploading_user.demo_id, uploaded_url)
  end

  protected
  
  def uploaded_url
    ["https://s3.amazonaws.com", @bucket, @key].join('/')
  end
end
