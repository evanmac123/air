class EmailCommandMailer < ActionMailer::Base
  DEFAULT_PLAY_ADDRESS = Rails.env.production? ? "play@playhengage.com" : "play-#{Rails.env}@playhengage.com"

  def send_response(email_command)
      @message  = email_command.response
      mail(:to      => email_command.user.email, 
           :from    => play_address(email_command.user.demo),
           :subject => "Got your message!")
  end

  def send_claim_response(email_command)
    @message = email_command.response
    @user = email_command.user

    mail(:to      => email_command.user.email, 
         :from    => play_address(email_command.user.demo),
         :subject => "Welcome to the game!")
  end

  protected

  def play_address(demo)
    demo.email.present? ? demo.email : DEFAULT_PLAY_ADDRESS
  end
end

