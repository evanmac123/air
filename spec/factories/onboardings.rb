# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :onboarding do
    organization factory: :organization
    board factory: :demo
  end
end
