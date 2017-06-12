# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    subscription nil
    due_date "2017-06-12 13:40:15"
    type_cd 1
    service_period_start "2017-06-12 13:40:15"
    service_period_end "2017-06-12 13:40:15"
    amount_in_cents 1
    description "MyText"
  end
end
