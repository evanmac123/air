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

    mail(:from    => 'Airbo Notifier<notify@airbo.com>',
         :to      => ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@airbo.com',
         :subject => 'Information Request -- Airbo Marketing Site')
  end
end
