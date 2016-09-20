class UserOnboarding < ActiveRecord::Base
  belongs_to :user
  belongs_to :onboarding
  attr_accessible :user, :onboarding, :state
  validates_presence_of :user_id
  validates_presence_of :onboarding_id
  after_create :set_state

  def set_state
    self.update_attributes(state: "first")
  end

  def update_state
    unless states[-1] == self.state
      new_state = states[states.index(state) + 1]
      self.update_attributes(state: new_state)
    end
  end

  def board
    onboarding.board
  end

  private

    def states
      ["first", "second", "third", "fourth"]
    end
end
