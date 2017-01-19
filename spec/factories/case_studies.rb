# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :case_study do
    client_name "MyString"
    description "MyText"
    industry "MyString"
  end
end
