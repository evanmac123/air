class BulkUploadNotificationMailer < ActionMailer::Base
  ADDRESS_TO_NOTIFY = (ENV['BULK_UPLOAD_NOTIFICATION_ADDRESS']) || 'kate@air.bo'

  default from: "bulkupload@air.bo"
  default to:   ADDRESS_TO_NOTIFY

  has_delay_mail

  def file_uploaded(user, board, uploaded_url)
    @uploaded_url = uploaded_url

    mail(
      subject: "Census file uploaded"
    )
  end
end
