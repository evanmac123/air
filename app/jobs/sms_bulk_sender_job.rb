# frozen_string_literal: true

class SmsBulkSenderJob < ActiveJob::Base
  queue_as :default

  def perform(user_ids:, body:)
    users = User.select(:phone_number).where(id: user_ids)
    users.each do |user|
      SmsSenderJob.perform_now(to_number: user.phone_number, body: body)
    end
  end
end
