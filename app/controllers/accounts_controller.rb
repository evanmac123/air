class AccountsController < ApplicationController
  def update
    phone_msg = update_phone_number
    current_user.attributes = params[:user].permit(:notification_method, :send_weekly_activity_report)

    if current_user.changed? && current_user.save
      flash[:success] = "Your account update request has been successfully processed. #{phone_msg}"
    end

    current_user.previous_changes.each do |field_name, changes|
      next if field_name == 'updated_at' || field_name == 'created_at'
      flash["mp_track_#{field_name}"] = ["changed #{field_name.humanize.downcase}", {:to => changes.last}]
    end

    redirect_to :back
  end

  protected

  def update_phone_number
    submitted_number = params[:user].delete(:phone_number)

    if submitted_number.blank? && current_user.phone_number.present?
      current_user.update_attributes(:phone_number => '')
      current_user.cancel_new_phone_number
      return "You will not longer receive text messages from us."
    end

    normalized_phone_number = PhoneNumber.normalize submitted_number
    if current_user.phone_number == normalized_phone_number
      current_user.cancel_new_phone_number
      return
    end

    current_user.new_phone_number = normalized_phone_number
    current_user.generate_short_numerical_validation_token
    if current_user.save
      current_user.send_new_phone_validation_token
      return "We have sent a verification code to #{current_user.new_phone_number.as_obfuscated_phone}. It will arrive momentarily. Please enter it into the Notification Preferences box below."
    else
      add_failure current_user.errors[:new_phone_number]
    end
  end
end
