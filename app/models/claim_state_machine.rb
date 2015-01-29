class ClaimStateMachine < ActiveRecord::Base
  serialize :states
  belongs_to :demo

  def find_unique_user(from, claim_information)
    claim_history = claim_attempt_histories.find_or_create_by_from(from, start_state_id, demo)
    claim_history.add_new_claim_information!(claim_information)
    claim_history.unique_user
  end

  def find_claim_state(claim_state_id)
    states[claim_state_id]
  end

  def start_state_id
    1
  end

  def claim_attempt_histories
    ClaimAttemptHistory
  end

  def self.default_claim_state_machine(demo)
    self.new(demo: demo, states: PredefinedMachines::DEFAULT_STYLE)
  end

  module PredefinedMachines
    COVIDIEN_THREE_STEP_STYLE = {
      1 => ClaimState.new(
        finder_method:                    :by_claim_code, 
        next_state_on_ambiguity_id:       2, 
        ambiguity_message:                "Sorry, we need a little more information to figure out who you are. Please send your 5-digit home ZIP code.", 
        unrecognized_information_message: "I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send \"jsmith\").", 
        already_claimed_message:          %(That ID "@{claim_information}" is already taken. If you're trying to register your account, please send in your own ID first by itself.)
      ),

      2 => ClaimState.new(
        finder_method:                    :by_zip_code, 
        next_state_on_ambiguity_id:       3, 
        ambiguity_message:                "Sorry, we need a little more info to create your account. Please send your month & day of birth (format: MMDD).", 
        valid_format:                     /^\d{5}$/, 
        invalid_format_message:           "Sorry, I didn't quite get that. Please send your 5-digit ZIP code.", 
        unrecognized_information_message: "Sorry, I don't recognize that ZIP code. Please try a different one, or contact support@airbo.com for help.",
        already_claimed_message:          "It looks like that account is already claimed. Please try a different ZIP code, or contact support@airbo.com for help."
      ),

      3 => ClaimState.new(
        finder_method:                    :by_date_of_birth_string, 
        next_state_on_ambiguity_id:       3, 
        ambiguity_message:                "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!",
        unrecognized_information_message: "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!",
        valid_format:                     /^\d{4}$/, 
        invalid_format_message:           "Sorry, I didn't quite get that. Please send your month & date of birth as MMDD (example: September 10 = 0910).", 
        already_claimed_message:          "It looks like that account is already claimed. Please try a different date of birth, or contact support@airbo.com for help."
    )}

    DEFAULT_STYLE = {
      1 => ClaimState.new(
        finder_method:                    :by_claim_code,
        next_state_on_ambiguity_id:       1, 
        unrecognized_information_message: "I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send \"jsmith\").",
        already_claimed_message:          "It looks like that account is already claimed. Please try again, or contact support@airbo.com for help.",
        ambiguity_message:                "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!"
      )
    }

    MICHELIN_STYLE = {
      1 => ClaimState.new(
        finder_method: :by_claim_code, 
        next_state_on_ambiguity_id: 2, 
        ambiguity_message: "Sorry, we need a little more information to figure out who you are. Please send E if you are a Michelin employee, S if the spouse of a Michelin employee.", 
        unrecognized_information_message: "Sorry, I don't recognize that. Please send your first initial and last name (if you're John Smith, send JSMITH)", 
        already_claimed_message: "It looks like you're already signed up. Please contact support@airbo.com if you need help."
      ),

      2 => ClaimState.new(
        finder_method: :by_employee_or_spouse_code, 
        next_state_on_ambiguity_id: 3, 
        ambiguity_message: "Sorry, we need a little more information to figure out who you are. Please send your CHORUS ID (or your spouse's if they're the Michelin employee).",
        unrecognized_information_message: "Sorry, I don't recognize that. Please send your CHORUS ID (or your spouse's if they're the Michelin employee)", 
        valid_format: /(e|E|s|S)/, 
        invalid_format_message: "Please send E if you are a Michelin employee, S if the spouse of a Michelin employee.", 
        already_claimed_message: "It looks like you're already signed up. Please contact support@airbo.com if you need help."
      ),

      3 => ClaimState.new(
        finder_method: :by_employee_id, 
        next_state_on_ambiguity_id: 3, 
        unrecognized_information_message: "Sorry, I don't recognize that. Please try sending your (or your spouse's) CHORUS ID for help, or contact support@airbo.com for help.", 
        valid_format: /^\d{8}$/, 
        invalid_format_message: "Sorry, I don't recognize that. Please try sending your (or your spouse's) CHORUS ID: it should be an 8-digit number.", 
        already_claimed_message: "It looks like you're already signed up. Please contact support@airbo.com if you need help."
      ),
    }
  end
end
