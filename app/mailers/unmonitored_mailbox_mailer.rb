class UnmonitoredMailboxMailer < ActionMailer::Base
  has_delay_mail
  helper :email
  layout 'mailer'

  default reply_to: 'support@airbo.com'

  def send_response(email_command)
    @response = email_command.response
    @demo = email_command.user.try(:demo)

    mail to:      email_command.email_from,
         subject: "Unmonitored mailbox",
         from:    email_command.user.try(:reply_email_address) || "Airbo <play@ourairbo.com>"
  end
end
