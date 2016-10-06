class UserOnboarding < ActiveRecord::Base
  belongs_to :user, autosave: true
  belongs_to :onboarding

  attr_accessible :user, :onboarding, :state
  validates_presence_of :user_id
  validates_presence_of :onboarding_id

  FINAL_STATE = 5

  before_create :set_auth_hash

  def validate_token(token)
    token == generate_token
  end

  def update_state
    unless state == final_state
      self.update_attributes(state: state + 1)
    end
  end

  def board
    onboarding.board
  end

  def final_state
    FINAL_STATE
  end

  def percent_complete
    (state.to_f / final_state) * 100
  end

  def completed
    state == FINAL_STATE
  end

  def regulate_progress(step)
    if (state + 1) < step
      "locked"
    elsif state >= step
      "complete"
    end
  end


  private

  def set_auth_hash
    self.auth_hash = Digest::SHA1.hexdigest(user.email + salt)
  end

  def salt
    "#{onboarding.organization.name}-#{onboarding.id}"
  end
end
