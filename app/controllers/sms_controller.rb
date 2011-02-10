class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"
    self.response_body = 
      User.claim_account(params['From'], params['Body']) ||
      Act.parse(params['From'], params['Body'])
  end
end
