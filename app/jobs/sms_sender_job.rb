class SmsSenderJob < ActiveJob::Base
  queue_as :default

  def perform(to_number:, body:, from_number:, type:)
    return unless to_number.present?

    begin
      params = { to: to_number, body: body }

      if Rails.env.production? && type != 'tile_digest'
          params.merge!(messaging_service_sid: TWILIO_MESSAGE_SERVICE_ID)
      else
        params.merge!(from: from_number)
      end

      $twilio_client.messages.create(params)
    rescue Twilio::REST::RestError
      RemoveInvalidUserPhoneNumberJob.perform_later(phone_number: to_number)
    end
  end
end
