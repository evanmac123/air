class EmailInfoRequestNotifier < ActionMailer::Base
  default :from => "email_info_requested@air.bo"
  helper :email
  has_delay_mail

  def info_requested(email_info_request)
    begin
      @first_name = email_info_request.name.split.first
    rescue
      @first_name = email_info_request.name
    end

    @email_info_request = email_info_request

    mail(:from    => 'Airbo Notifier<notify@air.bo>',
         :to      => ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@air.bo',
         :subject => 'Information Request -- Airbo Marketing Site')
  end
end
