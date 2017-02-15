# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign do
    demo nil
    description "MyString"
    sequence(:name) { |n| "Campaign_#{n}" }
  end
end
