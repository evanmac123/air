module SMS
  def self.send(to, body)
    Twilio::SMS.create(:to   => to,
                       :from => TWILIO_PHONE_NUMBER,
                       :body => body)
  end

  def self.parse_and_reply(text)
    case text.downcase
    when "broccoli"
      "Yum. +2 points. Broccoli helps your body fight cancer. You're now in 1st place."
    when /^#plu/
      "Sweet. +2 points. Bananas help you fight cancer."
    when /^#walk/
      "Nice job. +1 point. Walking improves bone health."
    else
      "Sorry, we didn't understand. Try: #plu 4042"
    end
  end
end
