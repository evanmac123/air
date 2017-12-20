# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :subscription do
    organization nil
    subscription_plan nil
    cancelled_at "2017-06-13 22:15:39"
    chart_mogul_uuid "MyString"
  end
end
