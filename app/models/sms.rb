module SMS
  def self.send_message(to, body)
    return unless to.present? # no sending to blank numbers
    Twilio::SMS.create(:to   => to,
                       :from => TWILIO_PHONE_NUMBER,
                       :body => body)
  end
end
