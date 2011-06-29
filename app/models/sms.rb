module SMS
  def self.send_message(to, body, send_at = nil)
    return unless to.present? # no sending to blank numbers

    delay_params = send_at ? {:run_at => send_at} : {}

    Twilio::SMS.delay(delay_params).create(:to   => to,
                                           :from => TWILIO_PHONE_NUMBER,
                                           :body => body)
  end
end
