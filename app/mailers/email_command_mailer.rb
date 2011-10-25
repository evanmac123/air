class EmailCommandMailer < ActionMailer::Base
  PLAY_ADDRESS = Rails.env.production? ? "play@hengage.com" : "play-#{Rails.env}@hengage.com"

  default :from => PLAY_ADDRESS

  def send_response(email_command)
      @message  = email_command.response
      mail(:to => email_command.user.email, :subject => "Got your message!")
  end

end

