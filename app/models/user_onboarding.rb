class UserOnboarding < ActiveRecord::Base
  belongs_to :user
  belongs_to :onboarding

  validates_presence_of :user
  validates_presence_of :onboarding

  validates_associated :user

  FINAL_STATE = 4

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

  def organization
    onboarding.organization
  end

  def final_state
    FINAL_STATE
  end

  def in_process?
    self.persisted?
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

  def completed_tile_count
    "fix"
  end

  def board_tiles_count
    "fix"
  end

  private

  def set_auth_hash
    self.auth_hash = Digest::SHA1.hexdigest(user.email + salt)
  end

  def salt
    "#{onboarding.organization.name}-#{onboarding.id}"
  end
end
