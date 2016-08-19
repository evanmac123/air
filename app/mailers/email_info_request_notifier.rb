class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@airbo.com"
  helper :email
  has_delay_mail

  def info_requested(email_info_request)
    begin
      @first_name = email_info_request.name.split.first
    rescue
      @first_name = email_info_request.name
    end

    @email_info_request = email_info_request

    subject = get_subject(email_info_request.source)

    mail(:from    => 'Airbo Notifier<notify@airbo.com>',
         :to      => 'team@airbo.com',
         :subject => "#{subject} -- Airbo Marketing Site")
  end

  def get_subject(source)
    if source == "signup"
      "Signup Request"
    elsif source == "demo_request"
      "Demo Request"
    else
      "Information Request"
    end
  end
end
