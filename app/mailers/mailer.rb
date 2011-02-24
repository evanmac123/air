class Mailer < ActionMailer::Base
  default :from => "vlad@hengage.com"

  def invitation(user)
    @user = user

    mail :to      => user.email,
         :subject => "Invitation to demo H Engage"
  end

  def victory(user)
    @user = user

    mail :to      => user.demo.victory_verification_email,
         :subject => "HEngage victory notification: #{user.name} (#{user.email})"
  end
end
