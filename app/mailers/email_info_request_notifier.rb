class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@hengage.com"

  def info_requested(name, email)
    @name = name
    @email = email

    mail(:to      => 'vlad@hengage.com',
         :cc      => 'phil@hengage.com',
         :subject => 'Somebody requested information about The H Engages!')
  end
end
