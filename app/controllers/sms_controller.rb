class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"

    self.response_body = Command.parse(params['From'], params['Body'], :allow_claim_account => true)
  end
end
