class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"

    # REMOVE this ridiculous hack after the conference

    if Time.now.utc >= Time.utc(2011, 03, 04, 15, 30, 00)
      command = params['Body'].strip.downcase
      self.response_body = if (command == 'more' || command == 'yes') 
                             MoreInfoRequest.create(:phone_number => params['From'], :command => command)
                             "Great, we'll be in touch. Stay healthy!" 
                           else
                             'The game is now done! Thanks for playing. If you\'d like us to e-mail you key stats (like amount of fruit eaten), text "yes". For more on H Engage, text "more"'
                           end
      return
    end

    self.response_body = 
      User.claim_account(params['From'], params['Body']) ||
      Act.parse(params['From'], params['Body'])
  end
end
