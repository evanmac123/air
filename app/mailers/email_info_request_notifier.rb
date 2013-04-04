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

    mail(:from    => 'H Engage Notifier<notify@hengage.com>',
         :to      => ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@hengage.com',
         :subject => 'Information Request -- H Engage Marketing Site')
  end
end
