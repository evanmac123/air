class SmsController < ActionController::Metal
  def create
    body = params['Body'].downcase
    from = params['From']

    if body.include?("broccoli")
      SMS.send(from, "Yum. +2 points. Broccoli helps your body fight cancer. You're now in 1st place.")
    elsif body.include?("#plu")
      SMS.send(from, "Sweet. +2 points. Bananas help you fight cancer.")
    elsif body.include?("#walk")
      SMS.send(from, "Nice job. +1 point. Walking improves bone health.")
    end
  end
end
