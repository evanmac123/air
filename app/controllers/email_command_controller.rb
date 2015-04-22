class EmailCommandController< ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  UNMONITORED_MAILBOX_RESPONSE = "Sorry, you've replied to an unmonitored account. For assistance please contact support@airbo.com.".freeze

  def create
    email_command = EmailCommand.create_from_incoming_email(params)      

    if email_command.looks_like_autoresponder? || email_command.too_soon_for_another_unmonitored_mailbox_reminder?
      email_command.update_attributes(status: EmailCommand::Status::SILENT_SUCCESS)
      set_silent_success_response!
    else
      email_command.set_attributes_for_unmonitored_mailbox_response
      set_success_response!
      UnmonitoredMailboxMailer.delay_mail(:send_response, email_command.id)
    end
  end

  protected

  def set_success_response!
    self.response_body = 'success'
    self.content_type  = "text/plain"
    self.status = 200
  end

  def set_silent_success_response!
    self.response_body = ''
    self.content_type  = "text/plain"
    self.status = 201
  end
end
