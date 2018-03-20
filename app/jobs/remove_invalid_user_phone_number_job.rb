class RemoveInvalidUserPhoneNumberJob < ActiveJob::Base
  queue_as :default

  def perform(phone_number:)
    user = User.find_by(phone_number: phone_number)

    if user
      user.update_attributes(phone_number: "")
    end
  end
end
