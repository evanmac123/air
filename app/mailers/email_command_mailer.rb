class EmailCommandMailer < ActionMailer::Base
  def send_response(email_command)
    @message = construct_reply_from_email_command(email_command)
    mail(:to      => email_command.user.email, 
         :from    => email_command.user.reply_email_address,
         :subject => "Got your message!")
  end

  def send_claim_response(email_command)
    @message = construct_reply_from_email_command(email_command)

    mail(:to      => email_command.user.email, 
         :from    => email_command.user.reply_email_address,
         :subject => "Welcome to the game!")
  end

  def send_response_to_non_user(email_command)
    @message = construct_reply_from_email_command(email_command)
    to_address = email_command.email_from
    mail(:to      => to_address, 
         :from    => DEFAULT_PLAY_ADDRESS,
         :subject => "Welcome to H Engage")
  end

  protected

  def construct_reply_from_email_command(email_command)
    @user = email_command.user
    construct_reply(email_command.response.dup)
  end
end

