class SmsSender
  def self.send_message(to_number:, body:, from_number: TWILIO_PHONE_NUMBER)
    return unless to_number.present?

    begin
      $twilio_client.messages.create(from: from_number, to: to_number, body: body)
    rescue StandardError => e
        Airbrake.notify(
          error_class: e.class,
          error_message: e.message,
          parameters: {
            from: from_number,
            to: to_number,
            body: body
          }
        )
    end
  end

  def self.bulk_send_messages(user_ids, body)
    users = User.where(id: user_ids).where(receives_sms: true)
    users.each { |user| SmsSender.send_message(to_number: user.phone_number, body: body) }
  end
end
