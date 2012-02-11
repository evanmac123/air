module OutgoingMessage
  DEFAULT_SIDE_MESSAGE_DELAY = ENV['SIDE_MESSAGE_DELAY'] || 5

  def self.send_message(to, body, send_at = nil, options = {})
    channels =
      case to
      when User: to.notification_channels
      when String:
        to.is_email_address? ? [:email] : [:sms]
      end

    if channels.include?(:sms)
      SMS.send_message(to, body, send_at, options)
    end

    if channels.include?(:email)
      recipient_identifier = to.kind_of?(User) ? to.id : to
      Mailer.delay.side_message(recipient_identifier, body)
    end
  end

  def self.send_side_message(to, body)
    send_message(to, body, Time.now + DEFAULT_SIDE_MESSAGE_DELAY)
  end
end
