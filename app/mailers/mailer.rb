class Mailer < ActionMailer::Base
  default :from => "vlad@hengage.com"

  def invitation(recipient)
    mail :to => recipient.email
  end
end
