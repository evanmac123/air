class SmsController < ActionController::Metal
  def create
    self.content_type  = "text/plain"
    self.response_body = Act.parse(params['From'], params['Body'])
  end
end
