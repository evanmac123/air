# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_onboarding do
    user nil
    onboarding nil
    state "MyString"
  end
end
