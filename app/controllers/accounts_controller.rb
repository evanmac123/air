class AccountsController < ApplicationController
  before_filter :initialize_flashes
  after_filter :merge_flashes

  def update
    update_phone_number
    current_user.attributes = params[:user]
    
    if current_user.save
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
      current_user.phone_number = ''
      add_success "OK, you won't get any more text messages from us."
      return
    end

    normalized_phone_number = PhoneNumber.normalize submitted_number
    return if current_user.phone_number == normalized_phone_number

    current_user.new_phone_number = normalized_phone_number
    current_user.generate_short_numerical_validation_token
    if current_user.save
      SMS.send_message current_user.new_phone_number, "Your code to verify this phone with H Engage is #{current_user.new_phone_validation}."
      add_success "We have sent a verification code to #{current_user.new_phone_number.as_pretty_phone}. It will arrive momentarily. Please enter it into the box below."
    else
      add_failure current_user.errors[:new_phone_number]
    end
  end
end
