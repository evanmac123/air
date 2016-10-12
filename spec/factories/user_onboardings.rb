FactoryGirl.define do
  factory :user_onboarding do
    user factory: :user
    onboarding factory: :onboarding
  end
end
