class GameCreationRequestMailer < ActionMailer::Base
  has_delay_mail

  def notify_ks(game_creation_request)
    @interests = game_creation_request.interests
    @name = game_creation_request.customer_name
    @email = game_creation_request.customer_email

    to_address = ENV['GAME_CREATION_REQUEST_ADDRESS'] || 'team_k@airbo.com'

    mail from:     "Game Creation Request <gamecreation@airbo.com>",
         to:       to_address,
         reply_to: "#{game_creation_request.customer_name} <#{game_creation_request.customer_email}>",
         subject:  "Game creation request from #{game_creation_request.customer_name} (#{game_creation_request.company_name})"
  end
end
