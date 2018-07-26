# frozen_string_literal: true

class SmsSenderJob < ActiveJob::Base
  queue_as :default

  def perform(to_number:, body:, from_number:)
    return unless to_number.present?

    begin
      params = { to: to_number, body: body }

      if Rails.env.production?
        params.merge!(from: TWILIO_SHORT_CODE)
      else
        params.merge!(from_number: from_number)
      end

      $twilio_client.messages.create(params)
    rescue Twilio::REST::RestError
      RemoveInvalidUserPhoneNumberJob.perform_later(phone_number: to_number)
    end
  end
end
