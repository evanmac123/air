# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :subscription_plan do
    name "MyString"
    interval_count 1
    interval_cd 1
  end
end
