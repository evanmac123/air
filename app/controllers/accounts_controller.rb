class AccountsController < ApplicationController
  skip_before_filter :authorize
  before_filter :authorize_without_guest_checks
  before_filter :initialize_flashes
  after_filter :merge_flashes

  def update
    update_phone_number
    current_user.attributes = params[:user].permit(:notification_method, :send_weekly_activity_report)

    if current_user.changed? && current_user.save
      add_success "Your account settings have been updated."
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
      add_success "OK, you won't get any more text messages from us."
      return
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
      add_success "We have sent a verification code to #{current_user.new_phone_number.as_pretty_phone}. It will arrive momentarily. Please enter it into the Notification Preferences box below."
    else
      add_failure current_user.errors[:new_phone_number]
    end
  end
end
