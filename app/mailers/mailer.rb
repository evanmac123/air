class Mailer < ActionMailer::Base
  default :from => "vlad@hengage.com"

  def invitation(user)
    @user = user

    mail :to      => user.email,
         :subject => "Invitation to demo H Engage"
  end
end
