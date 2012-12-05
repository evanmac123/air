class EmailCommandController< ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  def create
    # a status of 404 would reject the mail, we set a trivial body and a 200
    # status
    set_success_response!

    # Terrible, brutal hack to mitigate a mistaken email address printed on 11 billion little cards
    if params['to'].include? 'fujivote'
      message_text = %{
FUJI vote from #{params['from']}

Subject: #{params['subject']}

#{params['plain']}

      }

      Mailer.delay_mail(:side_message, 'fujivote@hengage.com', message_text)
      Mailer.delay_mail(:fuji_snafu_response, params['from'])
      return
    end

    email_command = EmailCommand.create_from_incoming_email(params)      
    if email_command.all_blank?
      email_command.response = blank_body_response
      email_command.status = EmailCommand::Status::SUCCESS
    elsif email_command.claim_account
      return # response sent from within claim_account
    else
      # Note: You can do any of commands but this one using either body or subject.
      # Perhaps someday we will allow general commands to be in the subject line
      email_command.parse_command
      email_command.status = EmailCommand::Status::SUCCESS
    end

    email_command.save

    # let DJ handle the email response
    EmailCommandMailer.delay_mail(:send_response, email_command)
  end

  protected

  def set_success_response!
    self.response_body = 'success'
    self.content_type  = "text/plain"
    self.status = 200
  end

  def blank_body_response
    "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body."
  end
end
