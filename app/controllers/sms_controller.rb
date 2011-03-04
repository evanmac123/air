class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"

    # REMOVE this ridiculous hack after the conference

    if Time.now.utc >= Time.utc(2011, 03, 04, 15, 30, 00)
      self.response_body = if (params['Body'].strip.downcase == 'more') 
                             MoreInfoRequest.create(:phone_number => params['From'])
                             "Great, we'll be in touch. Stay healthy!" 
                           else
                             'The game is now closed! Thanks for playing. If you would like to learn more information about H Engage, please respond with "more"'
                           end
      return
    end

    self.response_body = 
      User.claim_account(params['From'], params['Body']) ||
      Act.parse(params['From'], params['Body'])
  end
end
