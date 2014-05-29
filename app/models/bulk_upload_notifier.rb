class BulkUploadNotifier
  def initialize(uploading_user, bucket, key)
    @uploading_user = uploading_user
    @bucket = bucket
    @key = key
  end

  def notify_us_of_upload
    BulkUploadNotificationMailer.delay_mail(:file_uploaded, @uploading_user, @uploading_user.demo, uploaded_url)
  end

  protected
  
  def uploaded_url
    ["https://s3.amazonaws.com", @bucket, @key].join('/')
  end
end
