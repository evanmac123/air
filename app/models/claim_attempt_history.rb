class ClaimAttemptHistory < ActiveRecord::Base
  serialize :claim_information

  def add_new_claim_information!(claim_information)
    self.claim_information ||= {}
    self.claim_information[current_method] = claim_information
    save!
  end

  def unique_user
    if (format_error = check_for_claim_information_format_error)
      return [nil, format_error]
    end

    users = claim_information.inject(User) do |query, pair|
      query.send(*pair)
    end

    case users.length
    when 1
      user = users.first
      if user.claimed?
        [users.first, claim_state.already_claimed_message]
      else
        [users.first, nil]
      end
    when 0
      [nil, claim_state.unrecognized_information_message]
    else
      notify_admins(users) if claim_state.notify_admins_on_failure
      old_claim_state = claim_state
      update_attributes(claim_state_id: old_claim_state.next_state_on_ambiguity_id)
      [nil, old_claim_state.ambiguity_message]
    end
  end

  def claim_state_machine
    DefaultClaimStateMachine.new
  end

  def claim_state
    claim_state_machine.find_claim_state(claim_state_id)
  end

  def self.find_or_create_by_from(from, start_state_id)
    obj = self.where(from: from).first
    obj || self.create(from: from, claim_state_id: start_state_id)
  end

  protected

  def check_for_claim_information_format_error
    return nil unless (expected_format = claim_state.valid_format)
    return nil if expected_format =~ self.claim_information[current_method]
    claim_state.invalid_format_message
  end

  def current_method
    claim_state.finder_method
  end

  def notify_admins(users)
    ClaimTroubleMailer.delay.notify_admins(users)
  end
end
