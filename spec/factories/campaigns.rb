# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :campaign do
    demo nil
    description "MyString"
    sequence(:name) { |n| "Campaign_#{n}" }
  end
end
