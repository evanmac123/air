class SmsController < ActionController::Metal
  def create
    body = params['Body'].downcase
    from = params['From']

    player = Player.find_by_phone_number(from)

    Act.create(:player => player, :text => body)

    self.content_type  = "text/plain"
    self.response_body = SMS.parse_and_reply(body)
  end
end
