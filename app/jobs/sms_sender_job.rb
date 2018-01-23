class SmsSenderJob < ActiveJob::Base
  queue_as :default

  def perform(to_number:, body:, from_number:)
    return unless to_number.present?

    begin
      $twilio_client.messages.create(from: from_number, to: to_number, body: body)
    rescue Twilio::REST::RestError
      RemoveInvalidUserPhoneNumberJob.perform_later(phone_number: to_number)
    end
  end
end
