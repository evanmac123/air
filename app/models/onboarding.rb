class Onboarding < ActiveRecord::Base
  belongs_to :organization
  belongs_to :board, class_name: Demo, foreign_key: :demo_id

  has_many :user_onboardings, dependent: :destroy
  has_many :users, through: :user_onboardings, dependent: :destroy
  private

  def purge
    user_onboardings.destroy
    users.destroy
    organization.destroy
    board.destroy
    self.destroy
  end

end
