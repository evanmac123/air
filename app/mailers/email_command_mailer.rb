class EmailCommandMailer < ActionMailer::Base
  def send_response(email_command)
      @message  = email_command.response
      mail(:to      => email_command.user.email, 
           :from    => email_command.user.reply_email_address,
           :subject => "Got your message!")
  end

  def send_claim_response(email_command)
    @message = construct_reply(email_command.response.dup)
    @user = email_command.user

    mail(:to      => email_command.user.email, 
         :from    => email_command.user.reply_email_address,
         :subject => "Welcome to the game!")
  end

  def send_response_to_non_user(email_command)
    @message = email_command.response
    to_address = email_command.email_from
    mail(:to      => to_address, 
         :from    => DEFAULT_PLAY_ADDRESS,
         :subject => "Welcome to H Engage")
  end
end

