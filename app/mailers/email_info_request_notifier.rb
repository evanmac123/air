class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@hengage.com"
  helper :email
  has_delay_mail

  def info_requested(email_info_request)
    begin
      @first_name = email_info_request.name.split.first
    rescue
      @first_name = email_info_request.name
    end

    @email_info_request = email_info_request

    mail(:from    => 'H.Engage Notifier<notify@hengage.com>',
         :to      => ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@hengage.com',
         :subject => 'Information Request -- H.Engage Marketing Site')
  end
end
