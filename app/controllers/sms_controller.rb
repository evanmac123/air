class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"

    unless params['AccountSid'] == Twilio::ACCOUNT_SID
      self.response_body = ''
      self.status = 404
      return
    end

    self.response_body = Command.parse(params['From'], params['Body'], :allow_claim_account => true)
  end
end
