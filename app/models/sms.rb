module SMS
  def self.send(to, body)
    Twilio::SMS.create(:to   => to,
                       :from => TWILIO_PHONE_NUMBER,
                       :body => body)
  end
end
