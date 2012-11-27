class ClaimAttemptHistory < ActiveRecord::Base
  belongs_to :demo

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

    users = claim_information.inject(demo.users) do |query, pair|
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
      old_claim_state = claim_state
      update_attributes(claim_state_id: old_claim_state.next_state_on_ambiguity_id)
      [nil, old_claim_state.ambiguity_message]
    end
  end

  def claim_state_machine
    @_claim_state_machine ||= demo.claim_state_machine
    @_claim_state_machine
  end

  def claim_state
    claim_state_machine.find_claim_state(claim_state_id)
  end

  def self.find_or_create_by_from(from, start_state_id, demo)
    obj = self.where(from: from, demo_id: demo.id).first
    obj || self.create(from: from, claim_state_id: start_state_id, demo_id: demo.id)
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
end
