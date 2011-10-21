class EmailCommandMailer < ActionMailer::Base
  default :from => "donotreply@hengage.com"

  # Called whenever a message is received on the email command controller
  def receive(message)
    # TBD resolve these items from the message...

    #@name = name
    #@email = email
    #@comment = comment

    # TBD change here.
    mail(:to      => 'vlad@hengage.com',
         :cc      => 'phil@hengage.com',
         :subject => 'Somebody requested information about The H Engages!')

  end

end