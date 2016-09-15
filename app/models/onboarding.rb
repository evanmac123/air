class Onboarding < ActiveRecord::Base
  belongs_to :organization
  belongs_to :board, class_name: Demo, foreign_key: :demo_id
  has_many :user_onboardings, dependent: :destroy
end
