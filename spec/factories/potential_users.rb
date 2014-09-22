# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :potential_user do
    email "MyString"
    invitation_code "MyString"
    demo_id 1
  end
end
