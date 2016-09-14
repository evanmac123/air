class Onboarding < ActiveRecord::Base
  belongs_to :organization
  has_many :user_onboardings, dependent: :destroy
end
