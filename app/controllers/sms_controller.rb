class SmsController < ActionController::Metal
  def create
    body = params['Body'].downcase
    from = params['From']

    self.content_type = "text/plain"

    self.response_body = if body.include?("broccoli")
      "Yum. +2 points. Broccoli helps your body fight cancer. You're now in 1st place."
    elsif body.include?("#plu")
      "Sweet. +2 points. Bananas help you fight cancer."
    elsif body.include?("#walk")
      "Nice job. +1 point. Walking improves bone health."
    end
  end
end
