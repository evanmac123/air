# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :channel do
    sequence(:name) { |n| "Channel_#{n}" }
  end
end
