class SmsBulkSenderJob < ActiveJob::Base
  queue_as :default

  def perform(user_ids:, body:, from_number:)
    users = User.select(:phone_number).where(id: user_ids)
    users.each do |user|
      SmsSenderJob.perform_now(to_number: user.phone_number, body: body, from_number: from_number)
    end
  end
end
