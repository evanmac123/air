class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"
    self.response_body = SMS.parse_and_reply(params['Body'])
  end
end
