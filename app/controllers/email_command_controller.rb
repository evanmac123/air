class EmailCommandController< ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  UNMONITORED_MAILBOX_RESPONSE = "Sorry, you've replied to an unmonitored account. For assistance please contact support@air.bo.".freeze

  def create
    # a status of 404 would reject the mail, we set a trivial body and a 200
    # status
    set_success_response!

    email_command = EmailCommand.create_from_incoming_email(params)      

    if email_command.looks_like_autoresponder?
      email_command.update_attributes(status: EmailCommand::Status::SILENT_SUCCESS)
      set_silent_success_response!
      return
    else
      email_command.response = UNMONITORED_MAILBOX_RESPONSE
      email_command.status = EmailCommand::Status::SUCCESS
    end

    email_command.save

    # let DJ handle the email response
    UnmonitoredMailboxMailer.delay_mail(:send_response, email_command)
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
