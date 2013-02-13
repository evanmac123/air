class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@hengage.com"
  helper :email
  has_delay_mail

  def info_requested(name, email, phone, comment)
    @name = name
    begin
      @first_name = name.split.first
    rescue
      @first_name = name
    end
    @email = email
    @phone = phone
    @comment = comment
    snark_options = ['We must be making it! ',
                     'Hallelujah! ',
                     "We've really done it this time. ",
                     'I told you this would happen. ',
                     'See what happens when you take a great idea and you run with it? ',
                     'Get ready for the big time...',
                     'This could be the one...',
                     "One of us must be a frickin' genius. ",
                     'I kid you not--',
                     'Say hello to our new client: ']
    index = rand(snark_options.length)
    @snark = snark_options[index]

    if Rails.env.development? 
      @to = 'jack@sunni.ru'
      @cc = []
    else
      @to = 'vlad@hengage.com'
      @cc = ['phil@hengage.com', 'kim@hengage.com', 'kate@hengage.com']
    end
    mail(:from    => 'H Engage Notifier<notify@hengage.com>',
         :to      => @to,
         :cc      => @cc,
         :subject => 'Information Request -- H Engage Marketing Site')
  end
end
