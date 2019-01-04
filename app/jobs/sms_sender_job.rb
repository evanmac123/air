# frozen_string_literal: true

class SmsSenderJob < ActiveJob::Base
  queue_as :default

  def perform(to_number:, body:)
    return unless to_number.present? && User.find_by(phone_number: to_number).try(:receives_sms)

    begin
      $twilio_client.messages.create(to: to_number, body: body, from: TWILIO_SHORT_CODE)
    rescue Twilio::REST::RestError
      RemoveInvalidUserPhoneNumberJob.perform_later(phone_number: to_number)
    end
  end
end
