class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@hengage.com"

  def info_requested(name, email, comment)
    @name = name
    @email = email
    @comment = comment

    mail(:to      => 'vlad@hengage.com',
         :cc      => 'phil@hengage.com',
         :subject => 'H Engage Information Request')
  end
end
