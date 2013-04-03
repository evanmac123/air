class GameCreationRequestMailer < ActionMailer::Base
  has_delay_mail

  def notify_ks(game_creation_request)
    @interests = game_creation_request.interests

    to_address = ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@hengage.com'

    mail from:     "Game Creation Request <gamecreation@hengage.com>",
         to:       to_address,
         reply_to: "#{game_creation_request.customer_name} <#{game_creation_request.customer_email}>",
         subject:  "Game creation request from #{game_creation_request.customer_name} (#{game_creation_request.company_name})"
  end
end
