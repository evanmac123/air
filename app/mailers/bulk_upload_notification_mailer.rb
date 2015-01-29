class BulkUploadNotificationMailer < ActionMailer::Base
  ADDRESS_TO_NOTIFY = (ENV['BULK_UPLOAD_NOTIFICATION_ADDRESS']) || 'kate@airbo.com'

  default from: "bulkupload@airbo.com"
  default to:   ADDRESS_TO_NOTIFY

  has_delay_mail

  def file_uploaded(user_name, user_email, board_name, board_id, uploaded_url)
    @user_name = user_name
    @user_email = user_email
    @board_name = board_name
    @board_id = board_id
    @uploaded_url = uploaded_url

    mail(
      subject: "Census file uploaded"
    )
  end
end
