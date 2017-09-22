class User::PhoneUpdaterService
  attr_reader :user, :phone_number, :flash_type, :flash_msg

  def initialize(user:, phone_number:)
    @user = user
    @phone_number = PhoneNumber.normalize(phone_number)
  end

  def dispatch
    update_phone_number
    return self
  end

  def update_phone_number
    return blank_phone_number if phone_number.blank?
    return cancel_update if user.phone_number == phone_number

    user.new_phone_number = phone_number
    user.generate_new_phone_validation_token

    if user.save
      user.send_new_phone_validation_token
      @flash_type = :success
      @flash_msg = "We have sent a verification code to #{user.new_phone_number.as_obfuscated_phone}. It will arrive momentarily. Please enter it into the Notification Preferences box below."
    else
      @flash_type = :failure
      @flash_msg  = user.errors[:new_phone_number]
    end
  end

  def blank_phone_number
    if user.phone_number.present?
      user.update_attributes(phone_number: "")
      user.cancel_new_phone_number

      @flash_type = :success
      @flash_msg = "You will no longer receive text messages from us."
    end
  end

  def cancel_update
    user.cancel_new_phone_number
  end
end
