class EmailCommandMailer < ActionMailer::Base
  default :from => "donotreply@hengage.com"

  def send_response(email_command)
      @message  = email_command.response
      mail(:to => email_command.user, :subject => "Got your message!")
  end

end

