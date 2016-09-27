class UserOnboarding < ActiveRecord::Base
  belongs_to :user
  belongs_to :onboarding
  attr_accessible :user, :onboarding, :state
  validates_presence_of :user_id
  validates_presence_of :onboarding_id

  def update_state
    unless state == final_state
      self.update_attributes(state: state + 1)
    end
  end

  def board
    onboarding.board
  end

  def final_state
    5
  end

  def percent_complete
    (state.to_f / final_state) * 100
  end

  def regulate_progress(step)
    if (state + 1) < step
      "locked"
    elsif state >= step
      "complete"
    end
  end
end
