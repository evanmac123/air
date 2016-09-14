class UserOnboarding < ActiveRecord::Base
  belongs_to :user
  belongs_to :onboarding
  attr_accessible :user, :onboarding, :state
  validates_presence_of :user_id
  validates_presence_of :onboarding_id
  after_create :update_state

  def update_state
    if onboarding.user_onboardings.count > 1
      self.update_attributes(state: "view_board")
    else
      self.update_attributes(state: "initial")
    end
  end
end
