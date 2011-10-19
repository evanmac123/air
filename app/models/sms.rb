module SMS
  DEFAULT_SIDE_MESSAGE_DELAY = ENV['SIDE_MESSAGE_DELAY'] || 5

  def self.send_message(to, body, send_at = nil)
    return unless to.present? # no sending to blank numbers

    delay_params = send_at ? {:run_at => send_at} : {}

    to_number = case to
                when String: to
                when User: to.phone_number
                end

    Twilio::SMS.delay(delay_params).create(:to   => to_number,
                                           :from => TWILIO_PHONE_NUMBER,
                                           :body => body)
  end

  def self.send_side_message(to, body)
    send_message(to, body, Time.now + DEFAULT_SIDE_MESSAGE_DELAY)
  end
end
