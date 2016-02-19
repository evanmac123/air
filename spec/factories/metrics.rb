# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :metric, :class => 'Metrics' do
    starting_customers 1
    added_customers 1
    cust_possible_churn 1
    cust_churned 1
  end
end
