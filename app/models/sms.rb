module SMS
  DEFAULT_SIDE_MESSAGE_DELAY = ENV['SIDE_MESSAGE_DELAY'] || 5

  def self.send_message(to, body, send_at = nil)
    return unless to.present? # no sending to blank numbers

    delay_params = send_at ? {:run_at => send_at} : {}

    from_number, to_number = case to
                when String: [TWILIO_PHONE_NUMBER, to]
                when User: [(to.demo.phone_number || TWILIO_PHONE_NUMBER), to.phone_number]
                end

    #Delayed::Job.enqueue(OutgoingMessageJob.new(from_number, to_number, body), delay_params)
    Twilio::SMS.delay(delay_params).create(:from => from_number, :to => to_number, :body => body)
  end

  def self.send_side_message(to, body)
    send_message(to, body, Time.now + DEFAULT_SIDE_MESSAGE_DELAY)
  end
end
