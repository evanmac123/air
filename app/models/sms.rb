module SMS
  DEFAULT_SIDE_MESSAGE_DELAY = ENV['SIDE_MESSAGE_DELAY'] || 5

  def self.send_message(to, body, send_at = nil, options={})
    return unless to.present? # no sending to blank numbers
    return if muted_user?(to)

    delay_params = send_at ? {:run_at => send_at} : {}

    from_number = if options[:from_demo]
                    options[:from_demo].phone_number || TWILIO_PHONE_NUMBER
                  else
                    case to
                      when String: TWILIO_PHONE_NUMBER
                      when User: (to.demo.phone_number || TWILIO_PHONE_NUMBER)
                    end
                  end

    to_number = case to
                  when String: to
                  when User: to.phone_number
                end

    if to.kind_of?(User)
      to.increment!(:mt_texts_today)
    end

    Delayed::Job.enqueue(OutgoingMessageJob.new(from_number, to_number, body), delay_params)
  end

  def self.send_side_message(to, body)
    send_message(to, body, Time.now + DEFAULT_SIDE_MESSAGE_DELAY)
  end

  protected

  def self.muted_user?(to)
    to.kind_of?(User) && to.last_muted_at.present? && to.last_muted_at > 24.hours.ago
  end
end
