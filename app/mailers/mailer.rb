class Mailer < ActionMailer::Base
  default :from => "vlad@hengage.com"

  def invitation(player)
    @player = player

    mail :to      => player.email,
         :subject => "Invitation to demo H Engage"
  end
end
